# "Better" Evernote Integration for Launchbar

The current Evernote integration in Launchbar version 6.8 (6140) has a few short comings that make it difficult to interact with Evernote through Launchbar. For example, search terms are concatenated with `%20` as in URL encoded space, there is no preview of found notes you could select from, and creating new notes does not work with Evernote more recent than version 5.

This Launchbar Action mitigates these short comings.


## TODOs

1. Features

    1. [X] Reduce saved searches to name as well as search and map to menu items

    1. [X] Debug mode via settings

    1. [X] Cmd+Return: Copy note link to clipboard

1. Refactoring

    1. Apple Script result should have own format and mapped to items like saved_searches

1. Select Icons

1. [X] Change Info.plist back to '.Evernote'

1. Fix minifying

1. Update Readme

1. Release

1. Future work

    1. Favorite notes via settings

    1. Open Search in Evernote main window

## Features

1. Search queries may make use of the full [Evernote Search Grammar](https://dev.evernote.com/doc/articles/search_grammar.php).

    For example:

    * `search terms` -- matches notes that contain these terms in its full text

    * `intitle:"Words in title"` -- maches notes with these words in the title

    * `created:day-1` -- matches notes created yesterday or today

    * `todo:*` -- matches notes that contain todos

    * etc. See the above link for more.

    You can open any matching note by navigating to the search result and pressing `<Return>`. The search results show the title, the date of the last modification, the tags -- if any --, and the notebook of each matching note.

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

1. If Evernote is not running, a search will start it automatically, grabbing the focus. Thus, Lauchbar loses the focus and needs to be re-invoked.

