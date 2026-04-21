---
title: "Hello World"
date: "2002-11-11"
categories: ["tools"]
tags: ["blog","linux"]
draft: false
cover:
  image: "/img/posts/logo-nibbleblog.svg"
  hidden: true
---

<img src="/img/posts/logo-nibbleblog.svg" alt="nimble image" width="150px" height="150px" style="float:left; padding-right:25px"  />

Back in 2002 I decided to start sharing technical documentation and this is the first post I ever wrote. It explains how to work with a piece of software called Nibbleblog. Shortly after I moved to Wordpress and nowadays (2021) I have switched to "Jekyll + GitHub Pages". I'm keeping this first `post` as a reference.

<br clear="left"/>
<!--more-->

| Note: Be aware that years later this software was found to have security issues |

My first `post` about the installation and configuration of [NibbleBlog](http://www.nibbleblog.com), a very simple engine for creating and managing my blog, based on XML files. It was the first time I set up my own blog, so it reminded me of my first challenge when learning to program -- it reminded me of the first challenge when opening "The C Programming Language, by Kernighan & Ritchie":

**Print the words: `hello, world`**

That's the main hurdle and to get past it you had to start with this:

```cpp
main()
{
        printf("hello, world\n");
}
```

Enough nostalgia, what matters now is... **writing the first post accessible from a browser**. The truth is these people did an excellent job -- simple, fast and productive. What more can I say, I recommend it. Later on I switched to WordPress, but I'm leaving some installation notes for Nibbleblog here as a reference.

Requirements for installation on Gentoo The process is straightforward: Install Apache and PHP (USE: simplexml). That's it. ## Installation Manually download the NibbleBlog ZIP from its [download page](http://www.nibbleblog.com/download/en/). Unzip it and copy all its contents to a directory accessible by Apache. Here's an example for my setup:

```shell
cd /data/www
unzip /home/luis/Desktop/nibbleblogv11_editor.zip
mv nibbleblog\ v1.1\ +\ editor/ blog.luispa.com
```

I create a new vhost pointing to the new directory:

```shell
cd /data/www/blog.luispa.com
find . -exec chown apache:apache {} \;
/etc/init.d/apache graceful
```

<br/>

## Configuration

Connect to your blog, on the admin page (something like [http://your.server.com/admin](http://your.server.com/admin)). The questions are very simple; if something went wrong, just delete the contents under the "content" subdirectory and try again. Blog access:

- As a "reader" [http://yourblog.yourdomain.com](http://yourblog.yourdomain.com)
- As "admin" [http://yourblog.yourdomain.com/admin](http://yourblog.yourdomain.com/admin)
- The rest is so intuitive it's not worth explaining

<br/>

## Search in NibbleBlog

What a surprise I got. After installing NibbleBlog and playing around with it for a while, I realized it doesn't include a "search engine".

The solution was simple: at [http://www.freefind.com](http://www.freefind.com) they have a free service (ad-supported) that basically consists of them hosting the search engine and indexing your pages. In five minutes you have it working. You just need to sign up, activate the "HTML" insertion Plugin in NibbleBlog and off you go. By the way, in November 2014 I switched to WordPress which does include a search engine :-)
