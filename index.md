---
layout: page
title: Dave's Site
tagline: I do random stuff and sometimes I write about it
---
{% include JB/setup %}


# Posts
<ul class="posts">
  {% for post in site.posts %}
    <li><span>{{ post.date | date_to_string }}</span> &raquo; <a href="{{ BASE_PATH }}{{ post.url }}">{{ post.title }}</a></li>
  {% endfor %}
</ul>
