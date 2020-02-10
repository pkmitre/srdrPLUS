# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

document.addEventListener 'turbolinks:load', ->

  return unless $( '.projects, .citations' ).length > 0

  do ->
    # Ajax call to filter the project list. We want to return a function here
    # to prevent it from being called immediately. Wrapper is to allow passing
    # param without immediate function invocation.
    filterProjectList = ( order ) ->
      ->
        $.get {
            url: '/projects/filter?q=' + $( '#project-filter' ).val() + '&o=' + order,
            dataType: 'script'
        }
        return

    # Everytime a user types into the search field we send an ajax request to
    # filter the list. Use delay to delay the call.
    $( '#project-filter' ).keyup ( e ) ->
      e.preventDefault()
      currentOrder = $( '.toggle-sort-order button.button.active' ).data( 'sortOrder' )
      delay filterProjectList( currentOrder ), 750
      return

    # There's a short flicker when the button gains focus which is ugly.
    # We prevent it by calling e.preventDefault(). However, this must happen
    # on mousedown because that's when an item gains focus.
    $( '.toggle-sort-order button' ).mousedown ( e ) ->
      e.preventDefault()
      if $( this ).hasClass( 'active' )
        return
      nextOrder = $( '.toggle-sort-order button.button.disabled' ).data( 'sortOrder' )
      # Since filterProjectList returns a function, we to call it immediately.
      filterProjectList( nextOrder )()
      return

    # Activates the search slider on the project index page.
    $( 'button.search' ).mousedown ( e ) ->
      e.preventDefault()
      $( '.search-field' ).toggleClass 'expand-search'
      $( '#project-filter' ).focus()
      return

    $( '.export-type-radio' ).on 'change', ( e ) ->
      if $( this ).is ':checked'
        export_button = $( this ).parents('.reveal').find( '.start-export-button' )
        link_string = $( export_button ).attr( 'href', $( this ).val() )

########## IMPORTERS
   # if $( 'body.projects.new' ).length == 1
   #   $( '#distiller-import-checkbox' ).on 'change', ( ) ->
   #     $( '.distiller-import-panel' ).toggleClass( 'hide' )
   #   $( '#json-import-checkbox' ).on 'change', ( ) ->
   #     $( '.json-import-panel' ).toggleClass( 'hide' )

    if $( 'body.projects.new' ).length == 1
      $( '.distiller-section-file-container' ).on 'cocoon:after-insert', ( _, insertedElem ) ->
        #$( '.key-questions-list' ).find( 'input.string' ).each ( i, kq_textbox ) ->
        #  op = new Option( $( kq_textbox ).val(), $( kq_textbox ).val(), false, false )
        #  $( insertedElem ).find( '.distiller-key-question-input' ).first().append op
        $( insertedElem ).find( '.distiller-section-input' ).select2( placeholder: "-- Select Section --", tags: true )

        # We want to copy key questions from existing section files after inserting a new section box
        $new_kq_input = $( insertedElem ).find( '.distiller-key-question-input' )
        if $( '.distiller-section-file-container select.distiller-key-question-input' ).length > 1
          $source_kq_input = $( '.distiller-section-file-container select.distiller-key-question-input' ).first()
          $source_kq_input.find( 'option' ).each ( _, kq_option ) ->
            $kq_option = $( kq_option )
            if $new_kq_input.find( 'option[value="' + $kq_option.val() + '"]' ).length == 0
              $new_kq_input.append( new Option( $kq_option.val(), $kq_option.val(), false, false ) )
            $new_kq_input.trigger 'change'

        $new_kq_input.select2( placeholder: "-- Select Key Question --", tags: true ).on 'change', ( e ) ->
          $isNew = $( this ).find( '[data-select2-tag="true"]' )
          if $isNew.length and $isNew.val() == $( this ).val()
            # find other kq select2's and add this kq to them as well
            $( '.distiller-section-file-container select.distiller-key-question-input' ).each ( _, kq_input ) ->
              $kq_input = $( kq_input )
              if $kq_input.find( 'option[value="' + $isNew.val() + '"]' ).length == 0
                $kq_input.append( new Option( $isNew.val(), $isNew.val(), false, false ) ).trigger 'change'
              $isNew.replaceWith new Option( $isNew.val(), $isNew.val(), false, true )

     # $( '.key-questions-list' ).on 'cocoon:after-remove', ( e, removedElem ) ->
     #   removed_kq_val = $( removedElem ).find( 'input.string' ).val()
     #   $( '.distiller-section-file-container' ).find( "select.distiller-key-question-input option[value=\'" + removed_kq_val + "\']" ).remove()
     #   $( '.distiller-section-file-container' ).trigger( 'change' )

     # $( '.key-questions-list' ).on 'cocoon:after-insert', ( e, insertedElem ) ->
     #   textbox = $( insertedElem ).find( 'input.string' )
     #   $( textbox ).val('New Key Question ' + $( '.key-questions-list' ).find('input.string').length.toString())
     #   $( textbox ).on 'input', ( input_e ) ->
     #     option_name = $( input_e.target ).attr( 'data-option-name' )
     #     textbox_val = $( input_e.target ).val()
     #     $( '.distiller-section-file-container' ).find( 'select.distiller-key-question-input' ).each ( i, kq_input ) ->
     #       textbox_val = $( input_e.target ).val()
     #       old_option = $( kq_input ).find("option[value='"+option_name+"']")
     #       new_option = new Option( textbox_val, textbox_val, false, false )

     #       kq_select_val = $( kq_input ).val()
     #       if $( kq_input ).val() == $( old_option ).val()
     #         kq_select_val = $( new_option ).val()
     #       $( '.distiller-section-file-container' ).find( 'select.distiller-key-question-input' ).append( new_option )
     #       $( '.distiller-section-file-container' ).find( 'select.distiller-key-question-input' ).val( kq_select_val )
     #       $( old_option ).remove()
     #       $( '.distiller-section-file-container' ).trigger( 'change' )
     #       $( input_e.target ).attr( 'data-option-name' , $( new_option ).val() )
     #   newOption = new Option( $( textbox ).val(), $( textbox ).val(), false, false)
     #   $( '.distiller-section-file-container' ).find( 'select.distiller-key-question-input' ).append( newOption ).trigger( 'change' )
     #   $( textbox ).attr('data-option-name', $( newOption ).val() )

      $( '#create-type' ).on 'change', ( e ) ->
        $( '.input.file input' ).val('')
        if $( e.target ).val() == "empty"
          $( '.distiller-import-panel' ).addClass( 'hide' )
          $( '.json-import-panel' ).addClass( 'hide' )
          $( '#distiller-remove-references-file' ).trigger "click"
          $( '#distiller-remove-section-file' ).trigger "click"
          $( '#remove-project-file' ).trigger "click"
          $( '.submit' ).removeClass( 'hide' )
          $( '.submit-with-confirmation' ).addClass( 'hide' )
        else if $( e.target ).val() == "distiller"
          console.log("OYOY")
          $( '.distiller-import-panel' ).removeClass( 'hide' )
          $( '.json-import-panel' ).addClass( 'hide' )
          $( '#distiller-add-references-file' ).trigger "click"
          $( '#distiller-add-section-file' ).trigger "click"
          $( '#remove-project-file' ).trigger "click"
          $( '.submit' ).addClass( 'hide' )
          $( '.submit-with-confirmation' ).removeClass( 'hide' )
        else if $( e.target ).val() == "json"
          $( '.distiller-import-panel' ).addClass( 'hide' )
          $( '.json-import-panel' ).removeClass( 'hide' )
          $( '#distiller-remove-references-file' ).trigger "click"
          $( '#distiller-remove-section-file' ).trigger "click"
          $( '#add-project-file' ).trigger "click"
          $( '.submit' ).addClass( 'hide' )
          $( '.submit-with-confirmation' ).removeClass( 'hide' )

    ########## TASK MANAGEMENT
    if $( 'body.projects.edit' ).length == 1
      $( '.project_tasks_projects_users_roles select' ).select2()
      #### LISTENERS
      $( '.tasks-container' ).on 'cocoon:before-insert', ( e, insertedItem ) ->
        insertedItem.fadeIn 'slow'
        insertedItem.css('display', 'flex')
      $( '.tasks-container' ).on 'cocoon:after-insert', ( e, insertedItem ) ->
        insertedItem.addClass( 'new-task' )
        $( insertedItem ).find( '.project_tasks_projects_users_roles select' ).select2()

      ######### PROJECTS USERS
      ## still inside projects edit view
      $( ".project_projects_users_user select" ).select2
        minimumInputLength: 0
        ajax:
          url: '/api/v1/users.json'
          dataType: 'json'
          delay: 100
          data: (params) ->
            q: params.term
            page: params.page || 1

      #### LISTENERS
      $( '#projects-users-table' ).on 'cocoon:after-insert', ( e, insertedItem ) ->
        $( insertedItem ).find( '.project_projects_users_user select' ).select2
          minimumInputLength: 0
          ajax:
            url: '/api/v1/users.json'
            dataType: 'json'
            delay: 100
            data: (params) ->
              q: params.term
              page: params.page || 1

######### CITATION MANAGEMENT
    ##### CHECK WHICH CONTROLLER ACTION THIS PAGE CORRESPONDS TO
    ##### ONLY RUN THIS CODE IF WE ARE IN INDEX CITATIONS PAGE
    if $( 'body.citations.index' ).length == 1
      # Dropzone for uploading citation files
      Dropzone.options.fileDropzone = {
        url: "/imported_files",
        autoProcessQueue: true,
        uploadMultiple: false,

        init: ()->
          wrapperThis = this

          this.on('sending', (file, xhr, formData) ->
            ris_type_id = $( "#dropzone-div input#ris-file-type-id" ).val()
            csv_type_id = $( "#dropzone-div input#csv-file-type-id" ).val()
            endnote_type_id = $( "#dropzone-div input#endnote-file-type-id" ).val()
            pubmed_type_id = $( "#dropzone-div input#pubmed-file-type-id" ).val()

            file_extension = file.name.split('.').pop()
            file_type_id = switch 
              when file_extension == 'ris' then ris_type_id
              when file_extension == 'csv' then csv_type_id
              when file_extension == 'enw' then endnote_type_id
              else pubmed_type_id

            formData.append("authenticity_token", $("#dropzone-div input[name='authenticity_token']").val())
            formData.append("projects_user_id", $("#dropzone-div").find("#imported_file_projects_user_id").val())
            formData.append("import_type_id", $("#dropzone-div").find("#imported_file_import_type_id").val())
            formData.append("file_type_id", file_type_id)
            formData.append("authenticity_token", $("#dropzone-div input[name='authenticity_token']").val())
          )

          this.on('success', (file, response) ->
            toastr.success('Citation file successfully uploaded. You will be notified by email when citaion import finishes.')
            wrapperThis.removeFile(file)
          )
          this.on('error', (file, error_message) ->
            toastr.error('ERROR: Cannot upload citation file.')
          )
      }

      new Dropzone( '#fileDropzone' )

      list_options = { valueNames: [ 'citation-numbers', 'citation-title', 'citation-authors', 'citation-journal', 'citation-journal-date', 'citation-abstract', 'citation-abstract' ] }

      ## Method to pull citation info from PUBMED as XML
      fetch_from_pubmed = ( pmid ) ->
        $.ajax 'https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi',
          type: 'GET'
          dataType: 'xml'
          data: { db : 'pubmed', retmode: 'xml', id : pmid }
          error: ( jqXHR, textStatus, errorThrown ) ->
            console.log errorThrown
            toastr.error( 'Could not fetch citation info from PUBMED' )
          success: ( data, textStatus, jqXHR ) ->
            return 0 unless ( $(data).find('ArticleTitle').text()? )
            name = $(data).find('ArticleTitle').text() || ''

            abstract = ''
            for node in $(data).find('AbstractText')
              abstract += $(node).text()
              abstract += "\n"

            authors = [ ]
            for node in $(data).find('Author')
              first_name = $(node).find('ForeName').text() || ''
              last_name = $(node).find('LastName').text() || ''
              authors.push( first_name + ' ' + last_name )

            keywords = [ ]
            for node in $(data).find('Keyword')
              keyword = $(node).text() || ''
              keywords.push( keyword )

            journal = {  }
            journal[ 'name' ] = $(data).find('Journal').find( 'Title' ).text() || ''
            journal[ 'issue' ] = $(data).find('JournalIssue').find( 'Issue' ).text() || ''
            journal[ 'vol' ] = $(data).find('JournalIssue').find( 'Volume' ).text() || ''
            ## My philosophy is to use publication year whenever possible, as researchers seem to be most concerned about the year, and it is easier to parse and sort - Birol

            dateNode = $(data).find('JournalIssue').find( 'PubDate' )

            if $( dateNode ).find( 'Year' ).length > 0
              journal[ 'year' ] = $( dateNode ).find( 'Year' ).text()
            else if $( dateNode ).find( 'MedlineDate' ).length > 0
              journal[ 'year' ] = $( dateNode ).find( 'MedlineDate' ).text()
            else
              journal[ 'year' ] = ''

            citation_hash = { name: name ,     \
                              abstract: abstract, \
                              authors: authors,  \
                              keywords: keywords, \
                              journal: journal }
            populate_citation_fields citation_hash

      populate_citation_fields = ( citation ) ->
        $( '.citation-fields' ).find( '.citation-name input' ).val citation[ 'name' ]
        $( '.citation-fields' ).find( '.citation-abstract textarea' ).val citation[ 'abstract' ]
        $( '.citation-fields' ).find( '.journal-name input' ).val citation[ 'journal' ][ 'name' ]
        $( '.citation-fields' ).find( '.journal-volume input' ).val citation[ 'journal' ][ 'vol' ]
        $( '.citation-fields' ).find( '.journal-issue input' ).val citation[ 'journal' ][ 'issue' ]
        $( '.citation-fields' ).find( '.journal-year input' ).val citation[ 'journal' ][ 'year' ]


        #$( '.citation-fields' ).find( '.AUTHORS input' ).val citation[ 'authors' ][ 0 ]
        for author in citation[ 'authors' ]
          authorselect = $('.AUTHORS select')
          $.ajax(
            type: 'GET'
            data: { q: author }
            url: '/api/v1/authors.json' ).then ( data ) ->
              # create the option and append to Select2
              option = new Option( data[ 'results' ][ 0 ][ 'text' ], data[ 'results' ][ 0 ][ 'id' ], true, true )
              authorselect.append(option).trigger 'change'
              # manually trigger the `select2:select` event
              authorselect.trigger
                type: 'select2:select'
                params: data: data[ 'results' ][ 0 ]
              return
        for keyword in citation[ 'keywords' ]
          keywordselect = $('.KEYWORDS select')
          $.ajax(
            type: 'GET'
            data: { q: keyword }
            url: '/api/v1/keywords.json' ).then ( data ) ->
              # create the option and append to Select2
              option = new Option( data[ 'results' ][ 0 ][ 'text' ], data[ 'results' ][ 0 ][ 'id' ], true, true )
              keywordselect.append(option).trigger 'change'
              # manually trigger the `select2:select` event
              keywordselect.trigger
                type: 'select2:select'
                params: data: data[ 'results' ][ 0 ]
              return

        return

      ## Method to populate citations list dynamically using ajax calls to api/v1/projects/:id/citations.json
      append_citations = ( page ) ->
        $.ajax $( '#citations-url' ).text(),
          type: 'GET'
          dataType: 'json'
          data: { page : page }
          error: (jqXHR, textStatus, errorThrown) ->
            toastr.error( 'Could not get citations' )
          success: (data, textStatus, jqXHR) ->
            to_add = []
            $( "#citations-count" ).html( data[ 'pagination' ][ 'total_count' ] )
            for c in data[ 'results' ]
              citation_journal = ''
              citation_journal_date = ''

              if 'journal' of c
                citation_journal = c[ 'journal' ][ 'name' ]
                citation_journal_date = ' (' + c[ 'journal' ][ 'publication_date' ] + ')'

              to_add.push { 'citation-title': c[ 'name' ],\
                'citation-abstract': c[ 'abstract' ],\
                'citation-journal': citation_journal,\
                'citation-journal-date': citation_journal_date,\
                'citation-authors': ( c[ 'authors' ].map( ( author ) -> author[ 'name' ] ) ).join( ', ' ),\
                'citation-numbers': ( c[ 'pmid' ] || 'N/A' ),\
                'citations-project-id': c[ 'citations_project_id' ] }

            if page == 1
              citationList.clear()

            citationList.add to_add, ( items ) ->
              list_index = ( page - 1 ) * items.length
              for item in items
                list_index_string = list_index.toString()
                $( '<input type="hidden" value="' + \
                    item.values()[ 'citations-project-id' ] + \
                    '" name="project[citations_projects_attributes][' + \
                    list_index_string + \
                    '][id]" id="project_citations_projects_attributes_' + \
                    list_index_string + '_id">' ).insertBefore( item.elm )
                $( item.elm ).find( '#project_citations_projects_attributes_0__destroy' )[ 0 ].outerHTML = \
                    '<input type="hidden" name="project[citations_projects_attributes][' + \
                    list_index_string + \
                    '][_destroy]" id="project_citations_projects_attributes_' + \
                    list_index_string + \
                    '__destroy" value="false">'

                list_index++
              citationList.reIndex()
              Foundation.reInit( $( '#citations-projects-list' ) )

            if data[ 'pagination' ][ 'more' ] == true
              append_citations(  page + 1 )
            else
              citationList.sort( $( '#sort-select' ).val(), { order: $( '#sort-button' ).attr( 'sort-order' ), alphabet: undefined, insensitive: true, sortFunction: undefined } )

      # start pulling citations
      append_citations( 1 )
      # initialize ListJs
      citationList = new List( 'citations', list_options )

      ##### LISTENERS
      if not $( '#citations').attr( 'listeners-exist' )
        ## handler for selecting input type
        $( '#import-select' ).on 'change', () ->
          $( '#import-ris-div' ).hide()
          $( '#import-csv-div' ).hide()
          $( '#import-pubmed-div' ).hide()
          $( '#import-endnote-div' ).hide()
          switch $( this ).val()
            when 'ris' then $( '#import-ris-div' ).show()
            when 'csv' then $( '#import-csv-div' ).show()
            when 'pmid-list' then $( '#import-pubmed-div' ).show()
            when 'endnote' then $( '#import-endnote-div' ).show()

        # display upload button only if a file is selected
        $( 'input.file' ).on 'change', () ->
          if !!$( this ).val()
            $( this ).closest( '.simple_form' ).find( '.form-actions' ).show()
          else
            $( this ).closest( '.simple_form' ).find( '.form-actions' ).hide()

        # handler for sorting citations
        $( '#sort-button' ).on 'click', () ->
          if $( this ).attr( 'sort-order' ) == 'desc'
            $( this ).attr( 'sort-order', 'asc' )
            $( this ).html( 'ASCENDING' )
          else
            $( this ).attr( 'sort-order', 'desc' )
            $( this ).html( 'DESCENDING' )
          citationList.sort( $( '#sort-select' ).val(), { order: $( this ).attr( 'sort-order' ), alphabet: undefined, insensitive: true, sortFunction: undefined } )

        $( '#sort-select' ).on "change", () ->
          citationList.sort( $( this ).val(), { order: $( '#sort-button' ).attr( 'sort-order' ), alphabet: undefined, insensitive: true, sortFunction: undefined } )

        # cocoon listeners
        # Note: some of the animations don't work well together and are disabled for now 
        $( '#cp-insertion-node' ).on 'cocoon:before-insert', ( e, citation ) ->
          $( '.cancel-button' ).click()
          #citation.slideDown('slow')
        $( '#citations' ).find( '.list' ).on 'cocoon:after-remove', ( e, citation ) ->
          $( '#citations-form' ).submit()
        #$( '#cp-insertion-node' ).on 'cocoon:before-remove', ( e, citation ) ->
          #$(this).data('remove-timeout', 1000)
          #citation.slideUp('slow')
        $( document ).on 'cocoon:after-insert', ( e, insertedItem ) ->
          $( insertedItem ).find( '.AUTHORS select' ).select2
            minimumInputLength: 0
            #closeOnSelect: false
            ajax:
              url: '/api/v1/authors.json'
              dataType: 'json'
              delay: 100
              data: (params) ->
                q: params.term
                page: params.page || 1
          $( insertedItem ).find( '.KEYWORDS select' ).select2
            minimumInputLength: 0
            #closeOnSelect: false
            ajax:
              url: '/api/v1/keywords.json'
              dataType: 'json'
              delay: 100
              data: (params) ->
                q: params.term
                page: params.page || 1

          $( insertedItem ).find( '#is-pmid' ).on 'click', () ->
            ## clean up the citation fields
            $( insertedItem ).find('.AUTHORS select').val(null).trigger('change')
            $( insertedItem ).find('.KEYWORDS select').val(null).trigger('change')
            $( insertedItem ).find('.citation-name input').val(null)
            $( insertedItem ).find('.citation-abstract textarea').val(null)
            $( insertedItem ).find('.journal-name input').val(null)
            $( insertedItem ).find('.journal-volume input').val(null)
            $( insertedItem ).find('.journal-issue input').val(null)
            $( insertedItem ).find('.journal-year input').val(null)

            ## fetch citations using value in "Accession Number"
            fetch_from_pubmed $( '.project_citations_pmid input' ).val()


          $( insertedItem ).find( '.citation-select' ).select2
            minimumInputLength: 0
            ajax:
              url: '/api/v1/citations/titles.json',
              dataType: 'json'
              delay: 100
              data: (params) ->
                q: params.term
                page: params.page || 1

          # submit form when "Save Citation" button is clicked
          $( insertedItem ).find( '.save-citation' ).on 'click', () ->
            $( '#citations-form' ).submit()

        # reload the citations after a form submission ( probably overkill )
        $( '#citations-form' ).bind "ajax:success", ( status ) ->
          append_citations( 1 )
          toastr.success('Save successful!')
          $( '.cancel-button' ).click()
        $( '#citations-form' ).bind "ajax:error", ( status ) ->
          append_citations( 1 )
          toastr.error('Could not save changes')

        $( '#citations' ).attr( 'listeners-exist', 'true' )


#    $( '#citations' ).find( '.list' ).on 'cocoon:before-remove', ( e, citation ) ->
#      remove_button = $( citation ).find( '.remove-button' )
#      if not $( remove_button ).hasClass( 'confirm' )
#        e.preventDefault()
#        $( remove_button ).addClass( 'confirm' )
#        setTimeout ( ->
#          $( remove_button ).removeClass( 'confirm' )
#      ), 5000
#      else
#        $(this).data('remove-timeout', 1000)
#        citation.slideUp('slow')

#    setup_remove_button = ( remove_button ) ->
#      remove_button.addEventListener "click", ( e ) ->
#        if not $( remove_button ).hasClass( 'confirm' )
#          $( remove_button ).addClass( 'confirm' )
#          setTimeout ( ->
#            $( remove_button ).removeClass( 'confirm' )
#        ), 1000
#
#    $.map( $( '.remove-button' ), setup_remove_button )

    #projects_users_roles_data_url = $( '.project_tasks_projects_users_roles' ).attr('data_url')
    #@console.log projects_users_roles_data_url
    #$.ajax projects_users_roles_data_url,
    #  type: 'GET'
    #  dataType: 'json'
    #  success: (data) ->
    #    $( '.project_tasks_projects_users_roles select' ).select2
    #      data: data['results']
    #$( '.citation_select' ).select2
    #  ajax:
    #    url: '/api/v1/citations',
    #    dataType: 'json'
    #    delay: 250
    #    data: (params) ->
    #      console.log params
    #      q: params.term
    #      page: params.page || 1
    #    processResults: (data, params) ->
    #      # The server may respond with params.page, set it to 1 if not.
    #      params.page = params.page || 1
    #      results: $.map(data.items, (i) ->
    #        id: i.id
    #        text: i.name
    #      )
    #  width: '75%'

      # Cocoon listeners.
    #$( document ).on 'cocoon:after-insert', ( e, insertedItem ) ->
    #  $( insertedItem ).addClass( 'added-item' )
    #  $( insertedItem ).find( 'citation-select' ).select2
    #    ajax:
    #      url: '/api/v1/citations',
    #      dataType: 'json'
    #      delay: 250
    #      data: (params) ->
    #        console.log params
    #        q: params.term
    #        page: params.page || 1
    #      processResults: (data, params) ->
    #        # The server may respond with params.page, set it to 1 if not.
    #        params.page = params.page || 1
    #        results: $.map(data.items, (i) ->
    #          id: i.id
    #          text: i.name
    #        )
    #    width: '75%'



#templateResult: formatResult
        #templateSelection: formatResultSelection

#      # Cocoon listeners.
#      .on 'cocoon:before-insert', ( e, insertedItem ) ->
#        insertedItem.fadeIn 'slow'
#
#      .on 'cocoon:after-insert', ( e, insertedItem ) ->
#        Foundation.reInit 'abide'
#
#      .on 'cocoon:before-remove', ( e, insertedItem ) ->
#        #!!! This isnt' working. Immediately disappears.
#        $( this ).data 'remove-timeout', 1000
#        insertedItem.fadeOut 'slow'
#
#      .on 'cocoon:after-remove', ( e, insertedItem ) ->
#        Foundation.reInit 'abide'
#
#      # Abide listeners.
#      # Make form errors visible on the tab links.
#      .on 'invalid.zf.abide', ( e, el ) ->
#        if $( el ).closest( 'fieldset' ).attr( 'class' ) == 'key-question-fieldset'
#          $( '#panel-key-question-label' ).html( '<span style="color: red;">(*) Key Question(s)</span>' )
#
#        if $( el ).closest( 'fieldset' ).attr( 'class' ) == 'project-information-fieldset'
#          $( '#panel-information-label' ).html( '<span style="color: red;">(*) Project Information</span>' )
#
#      .on 'valid.zf.abide', ( e, el ) ->
#        if $( el ).closest( 'fieldset' ).attr( 'class' ) == 'key-question-fieldset'
#          $( '#panel-key-question-label' ).html( 'Key Question(s)' )
#
#        if $( el ).closest( 'fieldset' ).attr( 'class' ) == 'project-information-fieldset'
#          $( '#panel-information-label' ).html( 'Project Information' )

#    change = ->
#      $("form input, form textarea").change( ->
#        $('a').click( ->
#          confirm('Unsaved changes. Are you sure?')
#        )
#      )
#
#    $(document).ready(change)
#
#    # the page has been parsed and changed to the new version and on DOMContentLoaded
#    $(document).on('page:change', change)

#    # Set the field to display from the result set.
#    formatResultSelection = (result, container) ->
#      result.text
#
#    # Markup result.
#    formatResult = (result) ->
#      if result.loading
#        return result.text
#      markup = '<span>'
#      if ~result.text.indexOf 'Pirate'
#        markup += '<img src=\'https://s-media-cache-ak0.pinimg.com/originals/01/ee/fe/01eefe3662a40757d082404a19bce33b.png\' alt=\'pirate flag\' height=\'32\' width=\'32\'> '
#      if ~result.text.indexOf 'New item: '
#        #!!! Maybe add some styling.
#        markup += ''
#      markup += result.text
#      if result.suggestion
#        markup += ' (suggested by ' + result.suggestion.first_name + ')'
#      markup += '</span>'
#      markup
#
#    # Bind select2 to key question selection.
#    $( '#project_key_question_ids' ).select2
#      minimumInputLength: 0
#      ajax:
#        url: '/projects/' + gon.project_id + '/key_questions.json'
#        dataType: 'json'
#        delay: 250
#        data: (params) ->
#          q: params.term
#          page: params.page
#        processResults: (data, params) ->
#          # The server may respond with params.page, set it to 1 if not.
#          params.page = params.page || 1
#          results: $.map(data.items, (i) ->
#            id: i.id
#            text: i.name
#            suggestion: i.suggestion
#          )
#      escapeMarkup: (markup) ->
#        markup
#      templateResult: formatResult
#      templateSelection: formatResultSelection

    return  # END do ->

  return  # END document.addEventListener 'turbolinks:load', ->
