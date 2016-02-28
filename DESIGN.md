# Key-value flat file system

We reuse this concept in several places, so here's the generic concept. I need to design a system of files that will survive a naive synchronization program like rsync, syncthing, or dropbox. The basic idea is to namespace everything by hexdigest (inspired by git). We need to go a step further, and allow multiple values to not overwrite each other. The way to do this is to mark each value with the timestamp it was created and the source of the value. For example, this means the key `kasefet_name_salt` would have values stored in the directory `37/e5dd3e5cec596227e8a768eb2dac1912769fa2c8a1547ce391143c78ebc1c4`, like this:

```
root
|--37
   |--e5dd3e5cec596227e8a768eb2dac1912769fa2c8a1547ce391143c78ebc1c4
      |--20160224.184012.laptop
      |--20160223.140554.phone
```

Device names can either be configured locally, or set via stable digest from the uname, or just use the hostname (may cause issues in VM images).

To select the value for a given key, just look for the last file in the directory (lexicographically). If the format YYYYMMDD-HHMMSS.device.extension is followed, then there should only be conflicts if two devices edited the value at the exact same time. In such a case, the device name itself is used as a tie breaker. If desired, milliseconds may be used as well.

This is stable enough for most purposes (and well within my use cases, assuming clock drift doesn't go over a few minutes).

I leave it as an exercise to the sync program to correctly identify deleted values, although keeping the history of a value is typically preferred. Please note that editing a file directly should NEVER happen. Once a file is written, it should never change (This can be enforced with a digest of the content in the filename).

# File format

A kasefet wallet has the following layout:

```
wallet
|--key
|--index
|  |--index
|--metadata (flat file kv directory)
|--ksft (flat file kv directory)
```

## key file

The key file contains the master encryption key for the wallet. This key is used to encrypt the flatfile kv values. Note that the key has two parts, the key and the iv (because we recommend operating in CBC mode).

Optionally, for debugging, a plaintext wallet can be created, which wouldn't have this file.

Note that it is left as an exercise to the user how to rotate the primary credentials. In practice, this will require forcing synchronization immediately following such a change.

## index directory

The index directory holds a single file, which is the index of logical key names to physical key names. If more than one file is in this directory, it's a strong hint that the index needs to be rebuilt.

## metadata directory

The metadata file contains wallet-level settings (optionally with an extension if not a simple key=value format file). Should be encrypted. The standard way to test if a password is correct is to attempt to decrypt and parse this file, looking for the kasefet.wallet_version key.

Required keys are:

```
kasefet.wallet_version
kasefet.name_salt
```

## ksft directory

Key names shouldn't be exposed, so we salt the keyname before pushing it into the flatfile kv driver. I'm on the fence if values should be moved when a key is renamed, or if the key should stay constant (maintained through an index file that knows how to map keys to digests)

The content of these files varies, and I'm not sure what format I'll use. It'll be more or less free text, that much I do know.
