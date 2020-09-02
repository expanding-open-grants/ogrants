var data = {
    "query": {
      "filtered": {
        "filter": { }
        }
      }
    };

const endpoint = "http://localhost:9200/";

$(document).ready(function() {
    $.ajax({
        method: "GET",
        url: endpoint + "_stats",
        crossDomain: true,  
        async: false,
        dataType : 'json',
        contentType: 'application/json'
    })
    .done(function(response) {
        $('#count').html(response._all.total.docs.count);
    });

    $('#endpoint').html(endpoint);

    $("form").submit(function(event) {
        event.preventDefault(); //prevent default action

        query = $("form input[type='text']").val();

        $.ajax({
            method: "GET",
            url: endpoint + "_search?pretty=true&q=" + query,
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
                    "title": hit._source.play_name,
                    "author": hit._source.speaker,
                    "status": hit._source.speech_number,
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
