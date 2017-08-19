module AE

  module ConsolePlugin

    class FeatureLinksToEditor

      # TODO: It would be best to test existence of filepaths on the Ruby side before rendering them as links.

      def initialize(app)
      end

      def get_javascript_string
<<-'JAVASCRIPT'
requirejs(['app', 'ace/ace'], function (app, ace) {

    ace.require('ace/lib/dom').importCssString("\
#consoleOutput .message .time {  \
    display: none;               \
}                                \
#consoleOutput .message .trace { \
    position: absolute;          \
    top: 0;                      \
    right: 0;                    \
    opacity: 0.5;                \
}                                \
    ")

    function getBasename (filepath) {
        return filepath.match(/(?:[^\\\/]+)?$/)[0];
    }

    app.output.addListener('added', function (entryElement, text, metadata) {
        if (/puts|print/.test(metadata.type)) {
            // Add first trace to message.
            if (metadata.backtrace && metadata.backtrace.length > 0) {
                var trace = metadata.backtrace[0], match, path, lineNumber;
                // Extract the path and line number from the beginning of a trace.
                // example: /folders/file.rb:10: in `method_name'
                // Assuming the path contains at least one delimiter (to exclude '(eval)').
                match = trace.match(/^(.+[\/\\].+)\:(\d+)(?:\:.+)?$/);
                if (!match) return;
                path = match[1];
                lineNumber = parseInt(match[2]);
                var link = $('<a href="#">').on('click', function () {
                    app.editor.open(path, lineNumber);
                    app.settings.getProperty('console_active').setValue(false); // app.switchToEditor();
                })
                .addClass('trace unselectable')
                .attr('data-text', getBasename(path) + ':' + lineNumber)
                .appendTo(entryElement);
            }
        } else if (/error|warn/.test(metadata.type)) {
            // Convert paths in backtrace into links.
            $('.backtrace *', entryElement).each(function (index, traceElement) {
                var path = $(traceElement).data('path');
                var lineNumber = $(traceElement).data('line-number');
                if (path && lineNumber) {
                    $(traceElement).html( $(traceElement).html().replace(/^(.+)(\:\d+)/, '<a href="#">$1</a>$2') )
                    .find('a').on('click', function () {
                        app.editor.open(path, lineNumber);
                        app.settings.getProperty('console_active').setValue(false); // app.switchToEditor();
                    });
                }
            });
            // Add first trace to message.
            if ($('.backtrace *', entryElement).length > 0) {
                var traceElement = $('.backtrace *', entryElement)[0];
                var path = $(traceElement).data('path');
                var lineNumber = $(traceElement).data('line-number');
                if (path && lineNumber) {
                    var link = $('<a href="#">').on('click', function () {
                        app.editor.open(path, lineNumber);
                        app.settings.getProperty('console_active').setValue(false); // app.switchToEditor();
                    })
                    .addClass('trace unselectable')
                    .attr('data-text', getBasename(path) + ':' + lineNumber)
                    .appendTo(entryElement);
                }
            }
        }
    });
});
JAVASCRIPT
      end

    end # class FeatureLinksToEditor

  end # module ConsolePlugin

end # module AE