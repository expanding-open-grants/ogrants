---
layout: none
search: exclude
---
id,link
{% for grant in site.grants %}
  {{ grant.path | slice: 8, 99 | replace: '.md', '' }},
  {% for lnk in grant.link %}
    <{{ lnk.title | strip_newlines }}>
  {% endfor %}
  <br />
{% endfor %}

{% assign beatles = "John, Paul, George, Ringo" | split: ", " %}
{{ beatles }}

{{ beatles | join: " and "}}

{% assign beatle = "John" %}
{{ beatle }}

{{ beatle | join: " and "}}