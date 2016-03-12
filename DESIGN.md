# Key-value flat file system

We reuse this concept in several places, so here's the generic concept. I need to design a system of files that will survive a naive synchronization program like rsync, syncthing, or dropbox. The basic idea is to namespace everything by hexdigest (inspired by git). We need to go a step further, and allow multiple values to not overwrite each other. The way to do this is to mark each value with the timestamp it was created and the source of the value. For example, this means the key `kasefet.name_salt` would have values stored in the directory `db/c39d7d6b239c2e20a31672ed979fed2b45c88748d06ba3be6bff85767b5d3d`, like this:

```
root
|--index
|  |--index
|--db
   |--c39d7d6b239c2e20a31672ed979fed2b45c88748d06ba3be6bff85767b5d3d
      |--20160224.184012.laptop
      |--20160223.140554.phone
```

Device names can either be configured locally, or set via stable digest from the uname, or just use the hostname (may cause issues in VM images). The accuracy of the name can be configured (pid, tid), but should be stable throughout the lifetime of a system.

To select the value for a given key, just look for the last file in the directory (lexicographically). If the format YYYYMMDD-HHMMSS.device.extension is followed, then there should only be conflicts if two devices edited the value at the exact same time. In such a case, the device name itself is used as a tie breaker. Additional precision may be used, but the level of precision should not change throughout the lifetime of a system.

This is stable enough for most purposes (and well within my use cases, assuming clock drift is below change velocity).

I leave it as an exercise to the sync program to correctly identify deleted values, although keeping the history of a value is typically preferred. Please note that editing a file directly should NEVER happen. Once a file is written, it should never change (This can be enforced with a digest of the content in the filename).

## Encryption

When encrypting files in such a format, I like to keep them prefixed to the encrypted content and then the auth tag. Note that the first version only supports AES-256-GCM.

## File format

The actual format of the value files is a binary file with the magic number "KSFT". The layout is simple:

```
+-------------------------------------------------------------------------------------------+
| Magic Number | Key Length (32 bit big endian unsigned integer) | Key    | Value until EOF |
| KSFT         | 0x0006                                          | foobar | bazquux....     |
+-------------------------------------------------------------------------------------------+
```

## Index directory

The index is a quick way to convert/iterate over all the keys in a KV store.

There are two versions of the index file, which involve tradeoffs between change velocity and the likelihood of conflicts. The tradeoff is between storage size and expected velocity.

## Low-velocity index

This form is ideal for stores that don't change very often, as the index can be shared between all nodes, and generally doesn't need to be regenerated unless there's a conflict.

The idea is that there is a single "index" file, which gets updated each time there's a new key added, and it's left to the sync program to leave a "conflicted copy" of the file, which indicates that the index should be rebuilt automatically.

## High-velocity index

This is the preferred form if you expect to have many concurrent changes. In this approach, each node maintains its own view of the index, and regenerates it pretty much every single chance it gets. The drawback is that changes are not automatically detected, and the extra storage, which can be non-trivial if there are a large number of keys.

# Kasefet Password Wallets

A kasefet wallet has the following layout:

```
wallet
|--key
|--metadata (flat file kv directory)
|--ksft (flat file kv directory)
```

## key file

The key file contains the master encryption key for the wallet. This key is used to encrypt the flatfile kv values. When encrypted, the keyfile has this format:

```
+------------------------------------------------------+
| pbkdf2 salt (if any) | iv | auth_tag | encrypted key |
+------------------------------------------------------+
```

### Rotating credentials

When rotating credentials, it is recommended to simply reencrypt the keyfile with a new passphrase, and ensure consensus.

## index directory

The index directory holds a single file, which is the index of logical key names to physical key names. If more than one file is in this directory, it's a strong hint that the index needs to be rebuilt (sync programs that stick extra files everywhere are a plague on mankind)

## metadata directory

The metadata file contains wallet-level settings (optionally with an extension if not a simple key=value format file).

 Should be encrypted. The standard way to test if a password is correct is to attempt to decrypt and parse this file, looking for the kasefet.wallet_version key.

Required keys are:

```
kasefet.wallet_version
kasefet.name_salt
```

## ksft directory

Key names shouldn't be exposed, so we salt the keyname before pushing it into the flatfile kv driver. I'm on the fence if values should be moved when a key is renamed, or if the key should stay constant (maintained through an index file that knows how to map keys to digests)

The content of these files varies, and I'm not sure what format I'll use. It'll be more or less free text, that much I do know.
