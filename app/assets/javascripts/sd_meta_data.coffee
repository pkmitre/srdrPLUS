# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

class Timekeeper
  @_timer_dict: {}

  @create_timer_for_form: ( form ) -> 
    $( '.preview-button' ).attr( 'disabled', '' )
    formId = form.getAttribute( 'id' )
    if formId of @_timer_dict
      clearTimeout( @_timer_dict[formId] )
    @_timer_dict[ formId ] = setTimeout -> 
      send_async_form( form )
    , 750
    @_timer_dict[ formId ] 

# Set the field to display from the result set.
formatResultSelection = ( result, container ) ->
  result.text

# returns validation status of form
# also adds the class invalid to form inputs failing validation
validate_form_inputs = ( form ) ->
  $form = $( form )
  $form.find( '.invalid' ).removeClass( 'invalid' )
  is_form_valid = true
  # validate url inputs
  for input_elem in $form.find( '.url-input' )
    $input_elem = $( input_elem )
    input_val = $input_elem.val()
    is_input_valid = is_valid_URL( input_val ) || ( input_val == "" )
    if not is_input_valid
      $input_elem.addClass( 'invalid' ) 
    is_form_valid = is_form_valid && is_input_valid
  return is_form_valid

# Markup result.
formatResult = ( result ) ->
  if result.loading
    return result.text
  markup = '<span>'
  if ~result.text.indexOf 'Pirate'
    markup += '<img src=\'https://s-media-cache-ak0.pinimg.com/originals/01/ee/fe/01eefe3662a40757d082404a19bce33b.png\' alt=\'pirate flag\' height=\'32\' width=\'32\'> '
  if ~result.text.indexOf 'New item: '
    #!!! Maybe add some styling.
    markup += ''
  markup += result.text
  if result.suggestion
    markup += ' (suggested by ' + result.suggestion.first_name + ')'
  markup += '</span>'
  markup

# initiates select2 dropdowns
init_select2 = (selector, url) ->
  $( selector ).select2
    selectOnClose: true, # use TAB and ESC to select
    minimumInputLength: 0,
    placeholder: '-- Select or type other value --', # This wording is ambiguous
    ajax:
      url: url,
      dataType: 'json'
      delay: 250
      data: ( params ) ->
        q: params.term
        page: params.page
      processResults: ( data, params ) ->
        # The server may respond with params.page, set it to 1 if not.
        params.page = params.page || 1
        results: $.map( data.items, ( i ) ->
          id: i.id
          text: i.name
          suggestion: i.suggestion
        )
    escapeMarkup: ( markup ) ->
      markup
    templateResult: formatResult
    templateSelection: formatResultSelection

apply_all_select2 =() ->
  init_select2("#sd_meta_datum_funding_source_ids", '/funding_sources')
  init_select2("#sd_meta_datum_key_question_type_ids", '/key_question_types')
  init_select2(".sd_search_database", '/sd_search_databases')
  init_select2(".key_question", '/key_questions')
  init_select2(".key_question_type", '/key_question_types')
  sd_meta_datum_id = $(".sd_picods_key_question").data('sd-meta-datum-id')
  init_select2(".sd_picods_key_question", "/sd_key_questions?sd_meta_datum_id=" + sd_meta_datum_id)
  init_select2(".sd_picods_type", '/sd_picods_types')
  init_select2(".review_type", '/review_types')
  init_select2(".data_analysis_level", '/data_analysis_levels')

  $( '.apply-select2' ).select2( placeholder: '-- Select --' )

add_form_listeners =( form ) ->
  $form = $( form )
  # Use this to keep track of the different timers.
  formId = $form.attr( 'id' )
  $( form ).children( 'input' ).change ( e ) ->
    e.preventDefault()
    # Mark form as 'dirty'.
    $form.addClass( 'dirty' )

  $form.find( 'textarea, select, input' ).on 'change', ( e ) ->
    if not validate_form_inputs( form )
      return
    # Mark form as 'dirty'.
    $form.addClass( 'dirty' )
    Timekeeper.create_timer_for_form $form[0]

  $form.on 'cocoon:after-insert cocoon:after-remove', ( e ) ->
    # Mark form as 'dirty'.
    $form.addClass( 'dirty' )
    Timekeeper.create_timer_for_form $form[0]

  $( "a.remove-figure[data-remote]" ).on "ajax:success",  ( event ) ->
    $( this ).parent().closest( 'div' ).fadeOut();

  # Text Field.
  $form.keyup ( e ) ->
    e.preventDefault()

    # Ignore 'keyup' for a list of keys.
    code = e.keyCode || e.which;
    # 9: tab; 16: shift; 37: left-arrow; 38: up-arrow; 39: right-arrow; 40: down-arrow; 18: option; 91: cmd
    if code in [9, 16, 18, 37, 38, 39, 40, 91]
      return

    if not validate_form_inputs( form )
      return

    # Mark form as 'dirty'.
    $form.addClass( 'dirty' )
    Timekeeper.create_timer_for_form $form[0]

  $( '.fdatepicker' ).fdatepicker({format: 'yyyy-mm-dd', disableDblClickSelection: true}).show();

bind_srdr20_saving_mechanism = () ->
  $( 'form.sd-form' ).each ( i, form ) ->
    add_form_listeners( form )
    $cocoon_container = $( form ).parents( '.cocoon-container' )
    $cocoon_container.on 'sd:form-loaded', ( e ) ->
      add_form_listeners( $cocoon_container.children( 'form' ) )
      apply_all_select2()
  
document.addEventListener 'turbolinks:load', ->
  do ->
    return if $('body.sd_meta_data').length == 0

    bind_srdr20_saving_mechanism()
    apply_all_select2()

  return  # END document.addEventListener 'turbolinks:load', ->
