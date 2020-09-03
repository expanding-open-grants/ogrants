var data = {
    "query": {
      "filtered": {
        "filter": { }
        }
      }
    };

const endpoint = "http://localhost:9200/";
const index = "ogrants"

$(document).ready(function() {
    $.ajax({
        method: "GET",
        url: endpoint + index + "/_stats",
        crossDomain: true,  
        async: false,
        dataType : 'json',
        contentType: 'application/json'
    })
    .done(function(response) {
        $('.numgrant').html(response._all.total.docs.count);
    });

    $('#endpoint').html(endpoint);

    $("form").submit(function(event) {
        event.preventDefault(); //prevent default action

        query = $("form input[type='text']").val();

        $.ajax({
            method: "GET",
            url: endpoint + index + "/_search?pretty=true&size=999&q=" + query,
            crossDomain: true,  
            async: false,
            //data: JSON.stringify(data),
            dataType : 'json',
            contentType: 'application/json'
        })
        .done(function(response) {
            var template = $("#grantListTemplate").html();
            // TODO switch to structure for grants
            var result = {
                "count": response.hits.total.value
            };
            result.grants = response.hits.hits.map(hit => {
                return({
                    "title":  hit._source.title,
                    "author": hit._source.author,
                    "status": hit._source.status,
                    "year": hit._source.year,
                    "funder": hit._source.funder,
                    "program": hit._source.program,
                    "link": hit._source.link,
                    "url": hit._source.url,
                    "discipline": hit._source.discipline,
                    "score": hit._score
                });
            });
            
            var rendered = Mustache.render(template, result);
            $('#searchResults').html(rendered);
        })
        .fail(function(response) {
            console.log(response);
            $('#searchResults').html("Error retrieving grants!");
        });
    });
});
