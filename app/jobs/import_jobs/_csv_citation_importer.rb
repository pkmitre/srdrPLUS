def import_citations_from_csv(imported_file)
  primary_id = CitationType.find_by( name: 'Primary' ).id
  ### citation type, not sure if necessary
  #secondary_id = CitationType.find_by( name: 'Secondary' ).id
  #
  #row_d = { 'Primary' => primary_id, 'primary' => primary_id,
  #          'Secondary' => secondary_id, 'secondary' => secondary_id,
  #          '' => nil }

  h_arr = []

  file_string = imported_file.content.download.force_encoding('UTF-8').gsub(/(\r\n|\r|\n)/, "\n")

  CSV.parse( file_string, headers: :true ) do |row|
    key_counter = 0
    row_h = row.to_h
    cit_h = {}

    ### file encoding causes weird problems

    ### citation type, not sure if necessary
    #cit_type = row_h[ 'type' ]
    #if cit_type.present?
    #  row_h[ 'citation_type_id' ] = row_d[ cit_type ]
    #else
    #  row_h[ 'citation_type_id' ] = primary_id
    #end
    #row_h.delete 'type'
    cit_h[ 'citation_type_id' ] = primary_id


    ### keywords
    kw_str = row_h[ 'Keywords' ]
    if kw_str.present?
      kw_str.gsub! /"/, ''
      kw_arr = kw_str.split( "     " )
      if kw_arr.length == 1 then kw_arr = kw_str.split( /, |,/ ) end
      if kw_arr.length == 1 then kw_arr = kw_str.split( /; |;/ ) end
      if kw_arr.length == 1 then kw_arr = kw_str.split( / \/ |\// ) end
      if kw_arr.length == 1 then kw_arr = kw_str.split( / \| |\|/ ) end
      if kw_arr.length == 1 then kw_arr = kw_str.split( /\n/ ) end

      cit_h[ 'keywords_attributes' ] = {}
      kw_arr.each do |kw|
        cit_h[ 'keywords_attributes' ][Time.now.to_i + key_counter] = { name: kw }
        key_counter+=1
      end
    end

    ### authors
    au_str = row_h[ 'Authors' ]
    if au_str.present?
      au_str.gsub! /"/, ''
      au_arr = au_str.split( "     " )
      if au_arr.length == 1 then au_arr = au_str.split( /, |,/ ) end
      if au_arr.length == 1 then au_arr = au_str.split( / \/ |\// ) end
      if au_arr.length == 1 then au_arr = au_str.split( / \| |\|/ ) end
      if au_arr.length == 1 then au_arr = au_str.split( /\n| \n/ ) end

      cit_h[ 'authors_citations_attributes' ] = {}
      au_arr.each_with_index do |au, position|
        cit_h[ 'authors_citations_attributes' ][Time.now.to_i + key_counter] = { author_attributes: { name: au }, ordering_attributes: { position: (position + 1) } }
        key_counter+=1
      end
    end

    ### journal
    j_h = {}
    if row_h[ 'Journal' ].present? then j_h[ 'name' ] = row_h[ 'Journal' ].strip end
    if row_h[ 'Year' ].present? then j_h[ 'publication_date' ] = row_h[ 'Year' ].strip end
    if row_h[ 'Volume' ].present? then j_h[ 'volume' ] = row_h[ 'Volume' ].strip end
    if row_h[ 'Issue' ].present? then j_h[ 'issue' ] = row_h[ 'Issue' ].strip end
    cit_h[ 'journal_attributes' ] = j_h


    if row_h[ 'Title' ].present? then cit_h[ 'name' ] = row_h[ 'Title' ].strip end
    if row_h[ 'Abstract' ].present? then cit_h[ 'abstract' ] = row_h[ 'Abstract' ].strip end
    if row_h[ 'Accession Number' ].present? then cit_h[ 'pmid' ] = row_h[ 'Accession Number' ].strip end

    h_arr << cit_h
    if h_arr.length >= 500
      imported_file.project.citations << Citation.create(h_arr)
      h_arr = []
    end

    if h_arr.length >= CITATION_BATCH_SIZE
      imported_file.project.citations << Citation.create(h_arr)
      h_arr = []
    end
  end
  #imported_file.project.citations << Citation.create( h_arr )
end
