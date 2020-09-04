---
layout: none
search: exclude
---
id,link{% for grant in site.grants %}
{{ grant.path | slice: 8, 99 | replace: '.md', '' }},{{ grant.link | strip_newlines }}{% endfor %}

{% assign beatles = "John, Paul, George, Ringo" | split: ", " %}
{{ beatles }}

{{ beatles | join: " and "}}

{% assign beatle = "John" %}
{{ beatle }}

{{ beatle | join: " and "}}