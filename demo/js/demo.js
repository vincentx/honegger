$(function () {
    $(".add-section").click(function () {
        $("#composer").honegger('insertSection', $($(this).data("target"), "#column-templates").html());
    });
    $(".change-mode").click(function () {
        var mode = $(this).data("mode");
        $("#template").attr("class", $(this).data("mode"));
        $(".change-mode").removeClass("btn-primary");
        $(this).addClass("btn-primary");

        var composer = $("#composer");

        if (mode != 'layout') {
            disableLayoutMode(composer);
            composer.honegger('changeMode', mode, {});
        } else {
            composer.honegger('disable');
            enableLayoutMode(composer);
        }
    });

    $("#composer").honegger(
        {
            editableSelector: '.section-column',
            buttonHighlight: 'btn-primary',
            toolbar: '#composer-toolbar'
        }
    );

    for (var name in Demo.TemplateComponents) {
        $("#composer").honegger('installComponent', name, Demo.TemplateComponents[name]);
    }

    function disableLayoutMode(composer) {
        if (composer.hasClass('ui-sortable')) composer.sortable('disable');
        composer.find('.ui-sortable').each(function () {
            $(this).sortable('disable');
        });
    }

    function enableLayoutMode(composer) {
        composer.sortable(composer.hasClass('ui-sortable') ? 'enable' : {});
        composer.find('.section-block').each(function () {
            var block = $(this)
            if (!block.hasClass('single-block'))
                block.sortable(block.hasClass('ui-sortable') ? 'enable' : {});
        });
    }

    $(".add-component").click(function () {
        $("#composer").honegger('insertComponent', $(this).data("target"), {});
    });
});