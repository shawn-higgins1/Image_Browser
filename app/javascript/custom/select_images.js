$(document).on('turbolinks:load', function(){
    var controller = $("body").data('controller');
    var action = $("body").data('action');

    if(controller == "photos" && action == "gallery"){
        $('div.selectable').click(function () {
            $(this).toggleClass('selected');

            var ids = $("#delete-selected").data('ids');

            if(ids === undefined){
                ids = [];
            }

            if($(this).hasClass("selected")){
                ids.push($(this).data('id'));
            } else {
                ids.splice(ids.indexOf($(this).data('id')),1);
            }

            $("#delete-selected").data('ids', ids);

            var oldUrl = $("#delete-selected").attr("href").split('?')[0];
            var newUrl = oldUrl + "?" + jQuery.param({ids: ids});

            $("#delete-selected").attr("href", newUrl);
        });
    }
})