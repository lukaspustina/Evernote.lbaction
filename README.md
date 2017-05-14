# "Better" Evernote Integration for Launchbar

The current Evernote integration in Launchbar version 6.8 (6140) has a few short comings that make it difficult to interact with Evernote through Launchbar. For example, search terms are concatenated with `%20` as in URL encoded space, there is no preview of found notes you could select from, and creating new notes does not work with Evernote more recent than version 5.

This Launchbar Action mitigates these short comings.

## Features

1. Search queries may make use of the full [Evernote Search Grammar](https://dev.evernote.com/doc/articles/search_grammar.php).

    For example:

    * `search terms` -- matches notes that contain these terms in its full text

    * `intitle:"Words in title"` -- maches notes with these words in the title

    * `created:day-1` -- matches notes created yesterday or today

    * `todo:*` -- matches notes that contain todos

    * etc. See the above link for more.

    You can open any matching note by navigating to the search result and pressing `<Return>`.

1. Create new note

    You can easily create a new note in the default notebook by entering the new note's title as a search query and then pressing `<Shift>+<Return>`.

1. Open Evernote

    In case you want to open Evernote's main window, just press enter before entering a search query.


## Installation

1. Clone this repository

1. Deactivate the build-in Evernote integration in Launchbar's _Settings -> Index -> Show Indesx ->  Applications -> Evernote_.

1. Double click the cloned repository directory in Finder.


### Configuration

1. Number of search results

    You can change the number of presented search results my setting the variable `maxResults` in `suggestions.js` accordingly. The default value is 20. Please mind that increasing this value may have performance impacts.


## Known Limitations

1. Notes with titles containing `'` or `"` may not be handled correctly.

