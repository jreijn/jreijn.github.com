---
comments: false
date: "2015-06-17T00:00:00Z"
categories:
- Software Engineering
aliases:
- /2015/06/migrating_from_apache_to_nginx_proxy_cookie_paths
tags:
- nginx
- apache
title: Migrating From Apache to Nginx and proxying cookie paths
---

At work, I'm involved in a project which recently moved entirely to https. During the transition the project moved from Apache httpd as the proxy/web server to Nginx.

After the migration process al seemed fine and dandy. Everything got tested properly (we thought) and no issues were found, until we recently discovered a bug in production (yeah I know... ouch!). A large section of the forms on the site had stopped working. Initial investigation showed it had to do with an incorrect path, set in the cookie that was created for those forms. Because the path was incorrect the form never made it to the second step.

It actually turned out, we had a bug in our application for over a year, but the way we had set Apache mod\_proxy's ```ProxyPassReverseCookiePath``` directive, had hidden the problem. So with this post I'll try to explain a bit what we had and what the difference is between Apache mod\_proxy and Nginx proxy capabilities with regards to cookies.

## The problem

If you use cookies on your site, which you create from your Java based application you usually use something like:

``` java
Cookie cookie = new Cookie(COOKIE_NAME, value);
cookie.setSecure(true);
cookie.setMaxAge(30);
cookie.setPath(pathOnSite);
return cookie;
```

This creates a secure cookie, with a max age of 30 seconds and marks the cookie to be valid for a certain location on the site. The way our cookie was used, was only specific to one form, so on one URL. Hence the pathOnSite value was something like

```
/site/forms/myform.html
```

Because we proxy our site application, we wanted to get rid of the /site/ from the cookie path and this is where mod\_proxy ```ProxyPassReverseCookiePath``` comes to help out. Our virtual host configuration in Apache looks (simplified) similar to:

```
<VirtualHost *:80>
  ServerName www.example.com

  ProxyPreserveHost  On

  ProxyPass         / http://127.0.0.1:8080/site/
  ProxyPassReverse  / http://127.0.0.1:8080/site/
  ProxyPassReverseCookiePath  /site/ /
</VirtualHost>
```

Nice and simple right? Now after the migration we used a similar setup, but now with nginx

```
server {

  listen       80;
  server_name "www.example.com";

  location / {
    proxy_set_header Host $host;
    proxy_set_header X-Forwarded-Host $host;
    proxy_set_header X-Forwarded-Server $host;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;

    proxy_pass http://127.0.0.1:8080/site/;
    proxy_redirect default;
    proxy_cookie_path /site/ /;
  }

}

```

So far so good, but even though they look sort of the same, the culprit lies in how ```ProxyPassReverseCookiePath``` and ```proxy_cookie_path``` differ. Let's see what the mod\_proxy documentation says about ```ProxyPassReverseCookiePath```.

> Useful in conjunction with ProxyPassReverse in situations where backend URL paths are mapped to public paths on the reverse proxy. This directive rewrites the path string in Set-Cookie headers. If the beginning of the cookie path matches internal-path, the cookie path will be replaced with public-path.

So in essence our configuration above with ``/site/ /`` means that if the cookie path contains */site/* it will replace the entire path with */*.

Now let's see what Nginx's proxy\_cookie\_path documentation says:

> Sets a text that should be changed in the path attribute of the “Set-Cookie” header fields of a proxied server response. Suppose a proxied server returned the “Set-Cookie” header field with the attribute “path=/two/some/uri/”. The directive
>
> proxy\_cookie\_path /two/ /;
>
> will rewrite this attribute to “path=/some/uri/”.


So in our case it will only replace that part of the entire path, which contains '/site/' with a '/'.

So as a result our Apache vhost configuration actually made *'/site/forms/myform.html'* into *'/'*, where as nginx made it into *'/forms/myform.html'*, which is actually what it should have been in the first place. Now you might wonder what's wrong with that, but in our case our application also did some url processing on the server-side. Our forms are stored in an alphabetical folder structure, because of the amount of forms, so typically a form called 'myform' would be stored in '/forms/m/myform.html'. The application would then remove the /m/ for nice looking URLs and SEO purposes. Because of the difference we now had a cookie path set to '/forms/m/myform.html', instead of '/forms/myform.html', which was what the browser uses to visit the page.

## 'A' solution

I personally like and prefer the way ```proxy_cookie_path``` works. Having the ability to only change a small segment of the cookie path, is much nicer and keeps inline with what a developer intended to do with the cookie. The quickest solution for us was to just use a regexp to mimic Apache mod\_proxy behaviour in Nginx:

```
proxy_cookie_path ~^/site/.*$ /;
```

Of course this is not the right solution, but this gave us time to do the proper fix within our application code and reverse the cookie path instruction at a later stage.
