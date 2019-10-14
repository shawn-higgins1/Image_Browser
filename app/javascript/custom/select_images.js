$(document).on('turbolinks:load', function(){
    var controller = $("body").data('controller');
    var action = $("body").data('action');

    // Only run when in the photos controller with the gallery action
    if(controller == "photos" && action == "gallery"){
        // For all photos that the user can select
        $('div.selectable').click(function () {
            $(this).toggleClass('selected');

            // Retrieve an array of ids for the currently selected photos
            var ids = $("#delete-selected").data('ids');

            // If the array is undefined initialize it
            if(ids === undefined){
                ids = [];
            }

            // Either remove or add the current photos id to the array
            // depending on whether it was selected or deselected
            if($(this).hasClass("selected")){
                ids.push($(this).data('id'));
            } else {
                ids.splice(ids.indexOf($(this).data('id')),1);
            }

            // Update the array of ids
            $("#delete-selected").data('ids', ids);

            // Update the delete link to specify the selected photos
            var oldUrl = $("#delete-selected").attr("href").split('?')[0];
            var newUrl = oldUrl + "?" + jQuery.param({ids: ids});

            $("#delete-selected").attr("href", newUrl);
        });
    }
})