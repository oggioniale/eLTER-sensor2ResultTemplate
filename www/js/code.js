$(document).ready(function() {
    // Function to get selected value.
    $('#requests').click(function () {
        $.get(value).success(function (response) {
            $("#code").value = response;
        });
    });
});

console.log("0");
$(document).ready(function () {
    $("#tasto").click(function () {
        // event.preventDefault();
        console.log("1");
        $.ajax({
            url: "pox",
            data: $('#code').val(),
            type: 'POST',
            contentType: "application/xml",
            dataType: "text",
            success: parse,
            error: function (xhr, ajaxOptions, thrownError) {
                console.log(xhr.status);
                console.log(thrownError);
            }
        });
        function parse(data) {
            $("#result").html('<textarea class="">' + data.toString() + '</textarea>');
            /*prettyPrint();*/
        }

        /*
         $.post("pox", { 'data': $('#xml').val }, function(data){
         console.log("2");
         // callback logic
         $("#result").val() = data;
         });
         */
        return false;
    });
});

var dummy = {
    attrs: {
        color: ["red", "green", "blue", "purple", "white", "black", "yellow"],
        size: ["large", "medium", "small"],
        description: null
    },
    children: []
};

var tags = {
    "!top": ["top"],
    "!attrs": {
        id: null,
        class: ["A", "B", "C"]
    },
    top: {
        attrs: {
            lang: ["en", "de", "fr", "nl"],
            freeform: null
        },
        children: ["animal", "plant"]
    },
    animal: {
        attrs: {
            name: null,
            isduck: ["yes", "no"]
        },
        children: ["wings", "feet", "body", "head", "tail"]
    },
    plant: {
        attrs: {name: null},
        children: ["leaves", "stem", "flowers"]
    },
    wings: dummy, feet: dummy, body: dummy, head: dummy, tail: dummy,
    leaves: dummy, stem: dummy, flowers: dummy
};

function completeAfter(cm, pred) {
    var cur = cm.getCursor();
    if (!pred || pred()) setTimeout(function () {
        if (!cm.state.completionActive)
            cm.showHint({completeSingle: false});
    }, 100);
    return CodeMirror.Pass;
}

function completeIfAfterLt(cm) {
    return completeAfter(cm, function () {
        var cur = cm.getCursor();
        return cm.getRange(CodeMirror.Pos(cur.line, cur.ch - 1), cur) == "<";
    });
}

function completeIfInTag(cm) {
    return completeAfter(cm, function () {
        var tok = cm.getTokenAt(cm.getCursor());
        if (tok.type == "string" && (!/['"]/.test(tok.string.charAt(tok.string.length - 1)) || tok.string.length == 1)) return false;
        var inner = CodeMirror.innerMode(cm.getMode(), tok.state).state;
        return inner.tagName;
    });
}

var editor = CodeMirror.fromTextArea(document.getElementById("code"), {
    mode: "xml",
    lineNumbers: true,
    extraKeys: {
        "'<'": completeAfter,
        "'/'": completeIfAfterLt,
        "' '": completeIfInTag,
        "'='": completeIfInTag,
        "Ctrl-Space": "autocomplete"
    },
    hintOptions: {schemaInfo: tags}
});