---
title: Sphinx With External Image Annoyance
layout: post
---

So today I was trying to clean up some of my Sphinx build warnings when 
rendering this site. I got everything fixed so I had no errors or warnings
except for this little guy right here (truncated for easier reading):

```
~/dpetzel.info.tinkerer/2011/12/16/developing_a_command_parser_based_zenpack.rst:328: WARNING: nonlocal image URI found: https://external.domain/image.png
```

{% highlight bash %}
~/dpetzel.info.tinkerer/2011/12/16/developing_a_command_parser_based_zenpack.rst:328: WARNING: nonlocal image URI found: https://external.domain/image.png
{% endhighlight %}

{% highlight python %}
~/dpetzel.info.tinkerer/2011/12/16/developing_a_command_parser_based_zenpack.rst:328: WARNING: nonlocal image URI found: https://external.domain/image.png
{% endhighlight %}
