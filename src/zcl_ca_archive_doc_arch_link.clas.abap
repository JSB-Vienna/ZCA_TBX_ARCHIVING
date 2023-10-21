"! <p class="shorttext synchronized" lang="en">CA-TBX: Archive content: ArchiveLink document</p>
CLASS zcl_ca_archive_doc_arch_link DEFINITION PUBLIC
                                              INHERITING FROM zcl_ca_archive_doc
                                              CREATE PUBLIC.

* P U B L I C   S E C T I O N
  PUBLIC SECTION.
*   i n s t a n c e   a t t r i b u t e s
    DATA:
*     s t r u c t u r e s
      "! <p class="shorttext synchronized" lang="en">Key attribute - ArchiveLink Document key</p>
      ms_key               TYPE zca_s_image_key READ-ONLY.

*   i n s t a n c e   m e t h o d s
    METHODS:
      "! <p class="shorttext synchronized" lang="en">Constructor</p>
      "!
      "! @parameter io_parent       | <p class="shorttext synchronized" lang="en">ArchiveLink + DMS: Archived content of a business object</p>
      "! @parameter is_connection   | <p class="shorttext synchronized" lang="en">Document (= connection entry)</p>
      "! @parameter iv_mandt        | <p class="shorttext synchronized" lang="en">Client (if cross-client usage)</p>
      "! @parameter iv_sort_by_time | <p class="shorttext synchronized" lang="en">X = Order by creation time (can be much slower than normal!)</p>
      "! @raising   zcx_ca_archive_content | <p class="shorttext synchronized" lang="en">Common exception: Error while handling ArchiveLink content</p>
      constructor
        IMPORTING
          io_parent       TYPE REF TO zcl_ca_archive_content
          is_connection   TYPE zca_s_toav0_ext
          iv_mandt        TYPE symandt
          iv_sort_by_time TYPE abap_bool DEFAULT abap_false
        RAISING
          zcx_ca_archive_content,

      "! <p class="shorttext synchronized" lang="en">Get meta data, like scanning date / -time and others</p>
      "!
      "! @parameter iv_comp_id | <p class="shorttext synchronized" lang="en">Component Id in generic form</p>
      "! @parameter result     | <p class="shorttext synchronized" lang="en">Meta data components of document</p>
      "! @raising   zcx_ca_archive_content | <p class="shorttext synchronized" lang="en">Common exception: Error while handling ArchiveLink content</p>
      get_meta_data
        IMPORTING
          iv_comp_id    TYPE sdok_filnm DEFAULT 'data*'   ##NO_TEXT
        RETURNING
          VALUE(result) TYPE scms_comps
        RAISING
          zcx_ca_archive_content,

      zif_ca_archive_doc~delete REDEFINITION,

      zif_ca_archive_doc~display REDEFINITION,

      zif_ca_archive_doc~get_document REDEFINITION,

      zif_ca_archive_doc~get_url REDEFINITION,

      zif_ca_archive_doc~insert REDEFINITION.


* P R O T E C T E D   S E C T I O N
  PROTECTED SECTION.
*   i n s t a n c e   a t t r i b u t e s
    DATA:
*     t a b l e s
      "! <p class="shorttext synchronized" lang="en">ArchiveLink components of document</p>
      mt_meta_data    TYPE al_components.

*   i n s t a n c e   m e t h o d s
    METHODS:
      "! <p class="shorttext synchronized" lang="en">Check if the doc attributes are activated in AL settings</p>
      "!
      "! @parameter rv_are_activated | <p class="shorttext synchronized" lang="en">X = Document attributes are activated</p>
      are_doc_attributes_activated
        RETURNING
          VALUE(rv_are_activated) TYPE abap_boolean,

      "! <p class="shorttext synchronized" lang="en">Get document type definition</p>
      "!
      "! @raising zcx_ca_archive_content | <p class="shorttext synchronized" lang="en">Common exception: Error while handling ArchiveLink content</p>
      get_doc_type_definition
        RAISING
          zcx_ca_archive_content,

      "! <p class="shorttext synchronized" lang="en">Get document type description</p>
      get_doc_type_description,

      "! <p class="shorttext synchronized" lang="en">Get document attributes</p>
      get_user_defined_attributes,

      "! <p class="shorttext synchronized" lang="en">Modify document attributes</p>
      modify_user_defined_attributes.


* P R I V A T E   S E C T I O N
  PRIVATE SECTION.
*   i n s t a n c e   m e t h o d s
    METHODS:
      "! <p class="shorttext synchronized" lang="en">Complete document class if missing or generic</p>
      "!
      "! @raising   zcx_ca_archive_content | <p class="shorttext synchronized" lang="en">Common exception: Error while handling ArchiveLink content</p>
      complete_missing_doc_class
        RAISING
          zcx_ca_archive_content,

      "! <p class="shorttext synchronized" lang="en">Complete document type if missing</p>
      "!
      "! @raising   zcx_ca_archive_content | <p class="shorttext synchronized" lang="en">Common exception: Error while handling ArchiveLink content</p>
      complete_missing_doc_type
        RAISING
          zcx_ca_archive_content,

      "! <p class="shorttext synchronized" lang="en">Create BO IMAGE or its delegation counterpart</p>
      "!
      "! @raising   zcx_ca_archive_content | <p class="shorttext synchronized" lang="en">Common exception: Error while handling ArchiveLink content</p>
      create_bo_image
        RAISING
          zcx_ca_archive_content,

      "! <p class="shorttext synchronized" lang="en">Get creation time for sorting</p>
      "!
      "! @parameter iv_sort_by_time | <p class="shorttext synchronized" lang="en">X = Order by creation time (can be much slower than normal!)</p>
      "! @parameter result          | <p class="shorttext synchronized" lang="en">Meta data components of document</p>
      "! @raising   zcx_ca_archive_content  | <p class="shorttext synchronized" lang="en">Common exception: Error while handling ArchiveLink content</p>
      get_creation_time
        IMPORTING
          iv_sort_by_time TYPE abap_bool
        RETURNING
          VALUE(result)   TYPE scms_comps
        RAISING
          zcx_ca_archive_content.

ENDCLASS.



CLASS zcl_ca_archive_doc_arch_link IMPLEMENTATION.

  METHOD are_doc_attributes_activated.
    "-----------------------------------------------------------------*
    "   Check whether the file attributes are activated in ArchiveLink settings
    "-----------------------------------------------------------------*
    rv_are_activated = xsdbool( mo_parent->ms_toacu-reserv1 EQ abap_true ).
  ENDMETHOD.                    "are_doc_attributes_activated


  METHOD complete_missing_doc_class.
    "-----------------------------------------------------------------*
    "   Complete document class if missing or generic
    "-----------------------------------------------------------------*
    "Local data definitions
    DATA:
      lv_doc_class         TYPE /uif/lrep_type.

    IF ms_data-reserve IS NOT INITIAL AND         "Doc class is set and not generic
       ms_data-reserve NE '*'.
      RETURN.
    ENDIF.

    IF ms_data-ar_object IS NOT INITIAL.
      get_doc_type_definition( ).
      lv_doc_class = ms_doc_type_def-doc_type.      "Use document class from doc. class definition

    ELSE.
      DATA(ls_meta_data) = get_meta_data( ).
      IF ls_meta_data-mimetype NA '/'.
        lv_doc_class = ls_meta_data-mimetype.

      ELSE.
        "Search document class via the MIME type of the document
        SELECT FROM toadd
             FIELDS doc_type
              WHERE mimetype EQ @ls_meta_data-mimetype
               INTO @lv_doc_class
                    UP TO 1 ROWS.
        ENDSELECT.
        IF sy-subrc NE 0.
          IF ls_meta_data-compid CS 'data*' OR
             ls_meta_data-compid CS '*.pg*'.
            "MIME type & does not exist in table TOADD
            RAISE EXCEPTION TYPE zcx_ca_archive_content
              EXPORTING
                textid   = zcx_ca_archive_content=>mime_type_not_defined
                mv_msgty = zcx_ca_archive_content=>c_msgty_e
                mv_msgv1 = CONV #( ls_meta_data-mimetype ).

          ELSE.
            "Get file extension as document class
            DATA(lo_data_access_obj) = NEW /ui2/cl_dps_dao( ).
            lo_data_access_obj->split_file_name_and_type(
                                                    EXPORTING
                                                      iv_filename = CONV #( ls_meta_data-compid )
                                                    IMPORTING
                                                      ev_type     = lv_doc_class ).
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.

    TRY.
        get_doc_class_definition( CONV #( lv_doc_class ) ).
        ms_data-reserve = lv_doc_class.

      CATCH zcx_ca_archive_content.
        "MIME type is missing and cannot be derived from file name
        RAISE EXCEPTION TYPE zcx_ca_archive_content
          EXPORTING
            textid   = zcx_ca_archive_content=>can_t_determine_doc_class
            mv_msgty = zcx_ca_archive_content=>c_msgty_e.
    ENDTRY.
  ENDMETHOD.                    "complete_missing_doc_class


  METHOD complete_missing_doc_type.
    "-----------------------------------------------------------------*
    "   Complete document type if missing
    "-----------------------------------------------------------------*
    IF ms_data-ar_object IS NOT INITIAL.
      RETURN.
    ENDIF.

    IF ms_data-reserve IS INITIAL.
      "Parameter '&1' has invalid value '&2'
      RAISE EXCEPTION TYPE zcx_ca_archive_content
        EXPORTING
          textid   = zcx_ca_archive_content=>param_invalid
          mv_msgty = zcx_ca_archive_content=>c_msgty_e
          mv_msgv1 = CONV #( ms_data-reserve ).
    ENDIF.

    "Search for document type via document class
    SELECT FROM toaom AS cd
                INNER JOIN toadv AS dt
                           ON dt~ar_object EQ cd~ar_object
         FIELDS dt~ar_object
          WHERE cd~sap_object EQ @mo_parent->ms_bo_key-typeid
            AND dt~doc_type   EQ @ms_data-reserve
           INTO TABLE @DATA(lt_doc_types_found).
    IF sy-subrc NE 0.
      "No document types found for BO &1 and document class &2
      RAISE EXCEPTION TYPE zcx_ca_archive_content
        EXPORTING
          textid   = zcx_ca_archive_content=>no_doc_type_found_to_doc_class
          mv_msgty = zcx_ca_archive_content=>c_msgty_e
          mv_msgv1 = CONV #( mo_parent->ms_bo_key-typeid )
          mv_msgv2 = CONV #( ms_data-reserve ).

    ELSE.
      CASE lines( lt_doc_types_found ).
        WHEN 1.
          ms_data-ar_object = lt_doc_types_found[ 1 ].

        WHEN OTHERS.
          "Determination of document type via document class &1 is not unique
          RAISE EXCEPTION TYPE zcx_ca_archive_content
            EXPORTING
              textid   = zcx_ca_archive_content=>determine_doc_type_failed
              mv_msgty = zcx_ca_archive_content=>c_msgty_e
              mv_msgv1 = CONV #( ms_data-reserve ).
      ENDCASE.
    ENDIF.
  ENDMETHOD.                    "complete_missing_doc_type


  METHOD constructor.
    "-----------------------------------------------------------------*
    "   Constructor
    "-----------------------------------------------------------------*
    super->constructor( io_parent     = io_parent
                        is_connection = is_connection
                        iv_mandt      = iv_mandt ).

    DATA(ls_meta_data) = get_creation_time( iv_sort_by_time ).

    complete_missing_doc_class( ).
    complete_missing_doc_type( ).

    get_doc_class_definition( CONV #( ms_data-reserve ) ).
    get_doc_class_description( ).

    get_doc_type_definition( ).
    get_doc_type_description( ).

    get_user_defined_attributes( ).

    create_bo_image( ).

    ms_key = CORRESPONDING #( ms_data ).
  ENDMETHOD.                    "constructor


  METHOD create_bo_image.
    "-----------------------------------------------------------------*
    "   Create BO IMAGE or its delegation counterpart
    "-----------------------------------------------------------------*
    TRY.
        "Complete key
        mbo_document        = zif_ca_c_wf_bos=>cbo_image.
        mbo_document-typeid = get_delegation_type( ).
        mbo_document-instid = CORRESPONDING zca_s_image_key( ms_data ).

        "Create BO instance for access to attributes and methods of BO
        mo_wfmacs_document  = NEW #( mbo_document ).

      CATCH zcx_ca_error INTO DATA(lx_catched).
        DATA(lx_error) =
             CAST zcx_ca_archive_content(
                    zcx_ca_error=>create_exception(
                             iv_excp_cls = zcx_ca_archive_content=>c_zcx_ca_archive_content
                             iv_class    = 'ZCL_CA_WF_EXEC_MACROS'
                             iv_method   = 'CONSTRUCTOR'
                             ix_error    = lx_catched ) )  ##no_text.
        IF lx_error IS BOUND.
          RAISE EXCEPTION lx_error.
        ENDIF.
    ENDTRY.
  ENDMETHOD.                    "create_bo_image


  METHOD get_creation_time.
    "-----------------------------------------------------------------*
    "   Get creation time for sorting
    "-----------------------------------------------------------------*
    IF iv_sort_by_time EQ abap_false  AND
       ms_data-ar_date IS NOT INITIAL.
      RETURN.
    ENDIF.

    "Determine storage time for component id 'data' for order by
    result = get_meta_data( 'data*' ) ##no_text.
    IF result IS INITIAL.
      result = get_meta_data( '*.pg*' ) ##no_text.
    ENDIF.
    ms_data-ar_time = result-comptimec.

    "Was scan date passed?
    IF ms_data-ar_date IS INITIAL.
      "No -> use from meta data
      ms_data-ar_date = result-compdatec.
    ENDIF.
  ENDMETHOD.                    "get_creation_time


  METHOD get_doc_type_definition.
    "-----------------------------------------------------------------*
    "   Get document type definition
    "-----------------------------------------------------------------*
    IF ms_doc_type_def IS INITIAL.
      "Get document type definition
      SELECT SINGLE * INTO  @ms_doc_type_def
                      FROM  toadv
                            USING CLIENT @mv_mandt
                      WHERE ar_object EQ @ms_data-ar_object.
      IF sy-subrc NE 0.
        "Document type & does not exist.
        RAISE EXCEPTION TYPE zcx_ca_archive_content
          EXPORTING
            textid   = zcx_ca_archive_content=>doc_type_not_exist
            mv_msgty = c_msgty_e
            mv_msgv1 = CONV #( ms_data-ar_object ).
      ENDIF.
    ENDIF.
  ENDMETHOD.                    "get_doc_type_definition


  METHOD get_doc_type_description.
    "-----------------------------------------------------------------*
    "   Get document type description
    "-----------------------------------------------------------------*
    IF ms_doc_type_descr IS INITIAL.
      "Get document type definition
      SELECT SINGLE * INTO  @ms_doc_type_descr
                      FROM  toasp
                            USING CLIENT @mv_mandt
                      WHERE ar_object EQ @ms_data-ar_object
                        AND language  EQ @sy-langu.
      "Nothing found in login language ...
      IF sy-subrc NE 0.
        DATA(lv_langu) = SWITCH spras( sy-langu
                                         WHEN 'E' THEN 'D'
                                         ELSE 'E' ) ##no_text.
        "... try again with English or German
        SELECT SINGLE * INTO  @ms_doc_type_descr
                        FROM  toasp
                              USING CLIENT @mv_mandt
                        WHERE ar_object EQ @ms_data-ar_object
                          AND language  EQ @lv_langu.
        IF sy-subrc NE 0.
          ms_doc_type_descr-ar_object  = ms_data-ar_object.
          ms_doc_type_descr-objecttext = 'No description found'(ndf).
        ENDIF.
      ENDIF.
    ENDIF.
  ENDMETHOD.                    "get_doc_type_description


  METHOD get_meta_data.
    "-----------------------------------------------------------------*
    "   Get meta data, like scanning date / -time and others
    "-----------------------------------------------------------------*
    "Local data definitions
    DATA:
      lv_timestamp  TYPE timestamp,
      lv_timestring TYPE string.

    "Get meta data of archived document from archive
    IF mt_meta_data IS INITIAL.
      CALL FUNCTION 'SCMS_AO_STATUS'
        EXPORTING
          mandt        = mv_mandt
          arc_id       = ms_data-archiv_id
          doc_id       = ms_data-arc_doc_id
        TABLES
          comps        = mt_meta_data
        EXCEPTIONS
          error_http   = 1
          error_kernel = 2
          error_archiv = 3
          error_config = 4
          OTHERS       = 5.
      IF sy-subrc NE 0.
        DATA(lx_error) =
                CAST zcx_ca_archive_content(
                           zcx_ca_error=>create_exception(
                                       iv_excp_cls = zcx_ca_archive_content=>c_zcx_ca_archive_content
                                       iv_function = 'SCMS_AO_STATUS'
                                       iv_subrc    = sy-subrc ) )  ##no_text.
        IF lx_error IS BOUND.
          RAISE EXCEPTION lx_error.
        ENDIF.
      ENDIF.

      LOOP AT mt_meta_data REFERENCE INTO DATA(lr_meta_data).
        "Convert all times into local time zone
        lv_timestring = lr_meta_data->compdatec && lr_meta_data->comptimec.
        lv_timestamp  = lv_timestring.
        CONVERT TIME STAMP lv_timestamp TIME ZONE sy-zonlo
                 INTO DATE lr_meta_data->compdatec
                      TIME lr_meta_data->comptimec.

        lv_timestring = lr_meta_data->compdatem && lr_meta_data->comptimem.
        lv_timestamp  = lv_timestring.
        CONVERT TIME STAMP lv_timestamp TIME ZONE sy-zonlo
                 INTO DATE lr_meta_data->compdatem
                      TIME lr_meta_data->comptimem.
      ENDLOOP.
    ENDIF.

    "Determine requested component
    "Determine requested component
    CASE lines( mt_meta_data ).
      WHEN 0.
        RETURN.

      WHEN 1.
        result = mt_meta_data[ 1 ].

      WHEN OTHERS.
        LOOP AT mt_meta_data INTO  result
                             WHERE compid CP iv_comp_id.
          EXIT.
        ENDLOOP.
    ENDCASE.
  ENDMETHOD.                    "get_meta_data


  METHOD get_user_defined_attributes.
    "-----------------------------------------------------------------*
    "   Get the document attributes if activated. Attributes are the
    "   file name and the individual description by the user.
    "-----------------------------------------------------------------*
    IF NOT are_doc_attributes_activated( ).
      RETURN.
    ENDIF.

    "Get document type attributes
    SELECT SINGLE FROM toaat USING CLIENT @mv_mandt
                FIELDS filename,  descr,
                       creator,   creatime AS ar_time
                 WHERE arc_doc_id EQ @ms_data-arc_doc_id
                  INTO CORRESPONDING FIELDS OF @ms_data.
  ENDMETHOD.                    "get_user_defined_attributes


  METHOD modify_user_defined_attributes.
    "-----------------------------------------------------------------*
    "   Insert/update document attributes if activated. Attributes are the
    "   original file name and the individual description by the user.
    "-----------------------------------------------------------------*
    IF NOT are_doc_attributes_activated( ) OR    "Attributes are not activated  OR
       ( are_doc_attributes_activated( )  AND    "they are activated, but no relevant field is set
         ms_data-filename IS INITIAL      AND
         ms_data-descr    IS INITIAL ).
      RETURN.
    ENDIF.

    "Get document type definition
    DATA(ls_doc_attributes) = CORRESPONDING toaat( ms_data MAPPING creatime = ar_time ).
    IF ls_doc_attributes-creatime IS INITIAL.
      TRY.
          ls_doc_attributes-creatime = get_meta_data( )-comptimec.

        CATCH zcx_ca_archive_content.
          ls_doc_attributes-creatime = sy-uzeit.
      ENDTRY.
    ENDIF.

    MODIFY toaat FROM @ls_doc_attributes.
  ENDMETHOD.                    "modify_user_defined_attributes


  METHOD zif_ca_archive_doc~delete.
    "-----------------------------------------------------------------*
    "   Delete a document (= connection)
    "-----------------------------------------------------------------*
    "Delete archive connection
    cl_alink_connection=>delete(
                            EXPORTING
                              link      = ms_data-s_al_conn
                            EXCEPTIONS
                              not_found = 1
                              OTHERS    = 2 ).
    IF sy-subrc EQ 0.
      DELETE FROM toaat WHERE arc_doc_id EQ ms_data-arc_doc_id.
      DELETE mo_parent->mt_docs WHERE table_line->ms_data-arc_doc_id EQ ms_data-arc_doc_id.

    ELSE.
      DATA(lx_error) = CAST zcx_ca_archive_content(
                                     zcx_ca_error=>create_exception(
                                                 iv_excp_cls = zcx_ca_archive_content=>c_zcx_ca_archive_content
                                                 iv_class   = 'CL_ALINK_CONNECTION'
                                                 iv_method  = 'DELETE'
                                                 iv_subrc    = sy-subrc ) )  ##no_text.
      IF lx_error IS BOUND.
        RAISE EXCEPTION lx_error.
      ENDIF.
    ENDIF.
  ENDMETHOD.                    "zif_ca_archive_doc~delete


  METHOD zif_ca_archive_doc~display.
    "-----------------------------------------------------------------*
    "   Display single document
    "-----------------------------------------------------------------*
    "Determine, if document can be displayed implace (in a container)
    is_implace_possible( ).

    IF ( mv_implace_possible EQ abap_false   AND
         iv_force_implace    EQ abap_false )  OR
         io_container        IS NOT BOUND.
      "Display archive object in corresponding application
      CALL FUNCTION 'ARCHIVOBJECT_DISPLAY'
        EXPORTING
          archiv_doc_id            = ms_data-arc_doc_id
          archiv_id                = ms_data-archiv_id
          language                 = sy-langu
          window_title             = CONV saewintitl( 'Archived document'(ado) )
        EXCEPTIONS
          error_archiv             = 1
          error_communicationtable = 2
          error_kernel             = 3.
      IF sy-subrc NE 0.
        DATA(lx_error) =
              CAST zcx_ca_archive_content(
                       zcx_ca_error=>create_exception(
                                 iv_excp_cls = zcx_ca_archive_content=>c_zcx_ca_archive_content
                                 iv_function = 'ARCHIVOBJECT_DISPLAY'
                                 iv_subrc    = sy-subrc ) )  ##no_text.
        IF lx_error IS BOUND.
          RAISE EXCEPTION lx_error.
        ENDIF.
      ENDIF.

    ELSE.
      "Display in viewe implace
      open_in_viewer( io_container = io_container
                      iv_url_add   = iv_url_add ).
    ENDIF.
  ENDMETHOD.                    "zif_ca_archive_doc~display


  METHOD zif_ca_archive_doc~get_document.
    "-----------------------------------------------------------------*
    "   Get document in binary format
    "-----------------------------------------------------------------*
    "Local data definitions
    DATA:
      lx_error    TYPE REF TO zcx_ca_archive_content,
      lt_cont_bin TYPE sdokcntbins,
      lt_acc_info TYPE STANDARD TABLE OF scms_acinf.

    IF mv_doc IS NOT INITIAL.
      result = mv_doc.

    ELSE.
      CALL FUNCTION 'SCMS_DOC_READ'
        EXPORTING
          mandt                 = mv_mandt
          stor_cat              = ms_data-storage_cat
          crep_id               = ms_data-archiv_id
          doc_id                = ms_data-arc_doc_id
        TABLES
          access_info           = lt_acc_info
          content_bin           = lt_cont_bin
        EXCEPTIONS
          bad_storage_type      = 1                " Storage Category Not Supported
          bad_request           = 2                " Unknown Functions or Parameters
          unauthorized          = 3                " Security Breach
          comp_not_found        = 4                " Document/ Component/ Content Repository Not Found
          not_found             = 5                " Document/ Component/ Content Repository Not Found
          forbidden             = 6                " Document or Component Already Exists
          conflict              = 7                " Document/ Component/ Administration Data is Inaccessible
          internal_server_error = 8                " Internal Error in Content Server
          error_http            = 9                " Error in HTTP Access
          error_signature       = 10               " Error when Calculating Signature
          error_config          = 11               " Configuration error
          error_format          = 12               " Incorrect Data Format (Structure Repository)
          error_parameter       = 13               " Parameter error
          error                 = 14               " Unspecified error
          OTHERS                = 15.
      IF sy-subrc NE 0.
        lx_error = CAST zcx_ca_archive_content(
                             zcx_ca_error=>create_exception(
                                       iv_excp_cls = zcx_ca_archive_content=>c_zcx_ca_archive_content
                                       iv_function = 'SCMS_DOC_READ'
                                       iv_subrc    = sy-subrc ) )  ##no_text.

        "Send a not so technical message leaving the details in previous
        "An error occurred while reading the document from the archive
        RAISE EXCEPTION TYPE zcx_ca_archive_content
          EXPORTING
            textid   = zcx_ca_archive_content=>reading_doc_failed
            previous = lx_error
            mv_msgty = c_msgty_e.
      ENDIF.

      "Get length from FM results
      READ TABLE lt_acc_info INTO  DATA(ls_acc_info)
                             INDEX 1.
      mv_doc_length = ls_acc_info-comp_size.

      "Convert table with too long lines for an attachment in a hex string
      CALL FUNCTION 'SCMS_BINARY_TO_XSTRING'
        EXPORTING
          input_length = mv_doc_length
        IMPORTING
          buffer       = mv_doc
        TABLES
          binary_tab   = lt_cont_bin
        EXCEPTIONS
          failed       = 1
          OTHERS       = 2.
      IF sy-subrc NE 0.
        lx_error = CAST zcx_ca_archive_content(
                             zcx_ca_error=>create_exception(
                                       iv_excp_cls = zcx_ca_archive_content=>c_zcx_ca_archive_content
                                       iv_function = 'SCMS_BINARY_TO_XSTRING'
                                       iv_subrc    = sy-subrc ) )  ##no_text.
        IF lx_error IS BOUND.
          RAISE EXCEPTION lx_error.
        ENDIF.
      ENDIF.
    ENDIF.

    "Cut off superfluous hex00
    result = mv_doc = mv_doc(mv_doc_length).
  ENDMETHOD.                    "zif_ca_archive_doc~get_document


  METHOD zif_ca_archive_doc~get_url.
    "-----------------------------------------------------------------*
    "   Get URL to display object
    "-----------------------------------------------------------------*
    "Local data definitions
    DATA:
      lx_error        TYPE REF TO zcx_ca_archive_content.

    "Generate URL using archive and document Id
    CALL FUNCTION 'SCMS_DOC_URL_READ'
      EXPORTING
        mandt                = mv_mandt
        stor_cat             = ms_data-storage_cat
        crep_id              = ms_data-archiv_id
        doc_id               = ms_data-arc_doc_id
        signature            = space
        "Frontend via SSL
        security             = 'FS' ##no_text
        http_url_only        = abap_true
        force_get            = abap_true
      IMPORTING
        url                  = result
      EXCEPTIONS
        error_config         = 1
        error_parameter      = 2
        error_signature      = 3
        http_not_supported   = 4
        docget_not_supported = 5
        not_accessable       = 6
        data_provider_error  = 7
        tree_not_supported   = 8
        not_supported        = 9
        OTHERS               = 10.
    IF sy-subrc NE 0.
      CALL FUNCTION 'SCMS_DOC_URL_READ'
        EXPORTING
          mandt                = mv_mandt
          stor_cat             = ms_data-storage_cat   "space
          crep_id              = ms_data-archiv_id
          doc_id               = ms_data-arc_doc_id
          signature            = space
          "Frontend
          security             = 'F' ##no_text
          http_url_only        = abap_true
          force_get            = abap_true
        IMPORTING
          url                  = result
        EXCEPTIONS
          error_config         = 1
          error_parameter      = 2
          error_signature      = 3
          http_not_supported   = 4
          docget_not_supported = 5
          not_accessable       = 6
          data_provider_error  = 7
          tree_not_supported   = 8
          not_supported        = 9
          OTHERS               = 10.
      IF sy-subrc NE 0.
        lx_error =
            CAST zcx_ca_archive_content(
                   zcx_ca_error=>create_exception(
                             iv_excp_cls = zcx_ca_archive_content=>c_zcx_ca_archive_content
                             iv_function = 'SCMS_DOC_URL_READ'
                             iv_subrc    = sy-subrc ) )  ##no_text.
        IF lx_error IS BOUND.
          RAISE EXCEPTION lx_error.
        ENDIF.
      ENDIF.
    ENDIF.

    CONCATENATE result
                iv_url_add INTO result.
  ENDMETHOD.                    "zif_ca_archive_doc~get_url


  METHOD zif_ca_archive_doc~insert.
    "-----------------------------------------------------------------*
    "   Insert a new document (= connection)
    "-----------------------------------------------------------------*
    "Set document class
    IF ms_data-reserve IS INITIAL.
      ms_data-reserve = ms_doc_type_def-doc_type.
    ENDIF.

    "Set archive Id from connection definition
    IF ms_data-archiv_id IS INITIAL.
      SELECT SINGLE archiv_id INTO  @ms_data-archiv_id
                              FROM  toaom
                                    USING CLIENT @mv_mandt
                              WHERE sap_object EQ @ms_data-sap_object
                                AND ar_object  EQ @ms_data-ar_object
                                AND ar_status  EQ @abap_true.
      IF sy-subrc NE 0.
        "No active link definition in table &1 for &2 &3
        RAISE EXCEPTION TYPE zcx_ca_archive_content
          EXPORTING
            textid   = zcx_ca_archive_content=>no_link_def
            mv_msgty = c_msgty_e
            mv_msgv1 = 'TOAOM' ##no_text
            mv_msgv2 = CONV #( ms_data-sap_object )
            mv_msgv3 = CONV #( ms_data-ar_object ).
      ENDIF.
    ENDIF.

    "Insert new archive connection
    ms_data-mandt    = mv_mandt.
    ms_data-filename = iv_filename.
    ms_data-descr    = iv_description.
    ms_data-ar_date  = COND #( WHEN ms_data-ar_date IS NOT INITIAL
                                 THEN ms_data-ar_date ELSE sy-datlo ).
    ms_data-creator  = COND #( WHEN iv_creator IS NOT INITIAL
                                 THEN iv_creator ELSE cl_abap_syst=>get_user_name( ) ).
    cl_alink_connection=>insert(
                            EXPORTING
                              link     = ms_data-s_al_conn
                              creator  = ms_data-creator        "These fields are only forwarded to the BAdI
                              descr    = ms_data-descr          "that can be implemented, but the INSERT into
                              filename = ms_data-filename       "the right table has to be done by ourself.
                            EXCEPTIONS
                              error    = 1
                              OTHERS   = 2 ).
    IF sy-subrc NE 0.
      DATA(lx_error) =
             CAST zcx_ca_archive_content(
                         zcx_ca_error=>create_exception(
                                     iv_excp_cls = zcx_ca_archive_content=>c_zcx_ca_archive_content
                                     iv_class   = 'CL_ALINK_CONNECTION'
                                     iv_method  = 'INSERT'
                                     iv_subrc    = sy-subrc ) )  ##no_text.
      IF lx_error IS BOUND.
        RAISE EXCEPTION lx_error.
      ENDIF.
    ENDIF.

    modify_user_defined_attributes( ).
  ENDMETHOD.                    "zif_ca_archive_doc~insert

ENDCLASS.
