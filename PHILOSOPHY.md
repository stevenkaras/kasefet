# The name

Kasefet is the hebrew word for "safe", (the locked box meaning of safe). Seemed as good as any, and wasn't taken on rubygems

# A bit of history

In the beginning, I used Keepass as part of PortableApps. I found quickly that this wasn't ideal, since it didn't work easily on Ubuntu (just because it doesn't crash, doesn't mean it's good). At the time, I thought it would be enough to simply leave the database in a shared mount between the two (I was dual booting for a while). After that, I put the database on Dropbox and started to access it from my phone. That didn't go over well. Dropbox would sometimes update and move the file out from underneath the android app, and cause other issues. Worse, it would sometimes do this after I had already added new credentials to the database from my phone (leaving me with conflicted copies at best, or sometimes just making them "disappear").

After a while, I came to the conclusion that the file format just wasn't good, and that there had to be a better way to do it, but I also took stock of how much time it would take me to do this, and decided against it.

The final impetus for me to start this project came when I started working on a new side project, but didn't want to mix credentials from different scopes into the same database. Worse, I wanted to share a portion of my password wallet, but not all of it. All of this pointed towards the need to "layer" multiple wallets together.

# Goals for Kasefet

- System integration
  - autotype
  - clipboard
- Dumb sync
  - Flat files make this possible
- Support for using multiple wallets simultaneously
- Best practice encryption
- CLI and GUI interfaces
- Cross platform support (Ubuntu, Mac, and Android, because that's what I use)
- API access (as in, run a server with the files, and access the credentials via the api)

It's a big project, and I doubt I'll get very far on my own, but like I've always said: "Aim for the sky, and hit the tree"

# Personal time

I don't have a ton of time to dedicate to this project, so here are my weekend goals (I only have a single day on the weekend to give, and maybe not even that):

1. gem structure + edit files
2. encryption
3. layer multiple wallets
4. clipboard integration (mac)
5. clipboard (ubuntu)
6. autotype (mac)
7. autotype (ubuntu)
