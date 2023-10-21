"! <p class="shorttext synchronized" lang="en">CA-TBX: Archive content: DMS document</p>
CLASS zcl_ca_archive_doc_dms DEFINITION PUBLIC
                                        INHERITING FROM zcl_ca_archive_doc
                                        CREATE PUBLIC.

* P U B L I C   S E C T I O N
  PUBLIC SECTION.
*   i n s t a n c e   a t t r i b u t e s
    DATA:
*     s t r u c t u r e s
      "! <p class="shorttext synchronized" lang="en">Key attribute - Document management system (DMS) key</p>
      ms_key               TYPE bapi_doc_keys READ-ONLY.

*   i n s t a n c e   m e t h o d s
    METHODS:
      "! <p class="shorttext synchronized" lang="en">Constructor</p>
      "!
      "! @parameter io_parent     | <p class="shorttext synchronized" lang="en">ArchiveLink + DMS: Archived content of a business object</p>
      "! @parameter is_connection | <p class="shorttext synchronized" lang="en">Connection entry (= document details)</p>
      "! @parameter iv_mandt      | <p class="shorttext synchronized" lang="en">Client (if cross-client usage)</p>
      "! @raising   zcx_ca_archive_content | <p class="shorttext synchronized" lang="en">Common exception: Error while handling ArchiveLink content</p>
      constructor
        IMPORTING
          io_parent     TYPE REF TO zcl_ca_archive_content
          is_connection TYPE zca_s_toav0_ext
          iv_mandt      TYPE symandt
        RAISING
          zcx_ca_archive_content,

      zif_ca_archive_doc~display REDEFINITION,

      zif_ca_archive_doc~get_document REDEFINITION,

      zif_ca_archive_doc~get_url REDEFINITION,

      zif_ca_archive_doc~insert REDEFINITION.


* P R O T E C T E D   S E C T I O N
  PROTECTED SECTION.
*   i n s t a n c e   m e t h o d s
    METHODS:
      "! <p class="shorttext synchronized" lang="en">Get active document version</p>
      "!
      "! @parameter result | <p class="shorttext synchronized" lang="en">Active document version</p>
      "! @raising   zcx_ca_archive_content | <p class="shorttext synchronized" lang="en">Common exception: Error while handling ArchiveLink content</p>
      get_active_version
        RETURNING
          VALUE(result) TYPE dokvr
        RAISING
          zcx_ca_archive_content,

      "! <p class="shorttext synchronized" lang="en">Get document status information</p>
      "!
      "! @raising   zcx_ca_archive_content | <p class="shorttext synchronized" lang="en">Common exception: Error while handling ArchiveLink content</p>
      get_doc_status_info
        RAISING
          zcx_ca_archive_content,

      "! <p class="shorttext synchronized" lang="en">Get DMS object data</p>
      "!
      "! @raising   zcx_ca_archive_content | <p class="shorttext synchronized" lang="en">Common exception: Error while handling ArchiveLink content</p>
      get_draw_data
        RAISING
          zcx_ca_archive_content.


* P R I V A T E   S E C T I O N
  PRIVATE SECTION.
*   i n s t a n c e   m e t h o d s
    METHODS:
      "! <p class="shorttext synchronized" lang="en">Create BO DRAW or its delegation counterpart</p>
      "!
      "! @raising   zcx_ca_archive_content | <p class="shorttext synchronized" lang="en">Common exception: Error while handling ArchiveLink content</p>
      create_bo_draw
        RAISING
          zcx_ca_archive_content.

ENDCLASS.



CLASS zcl_ca_archive_doc_dms IMPLEMENTATION.

  METHOD constructor.
    "-----------------------------------------------------------------*
    "   Constructor
    "-----------------------------------------------------------------*
    super->constructor( io_parent       = io_parent
                        is_connection   = is_connection
                        iv_mandt        = iv_mandt ).

    get_draw_data( ).

    create_bo_draw( ).

    ms_key = ms_data-s_doc_key.
  ENDMETHOD.                    "constructor


  METHOD create_bo_draw.
    "-----------------------------------------------------------------*
    "   Create BO DRAW or its delegation counterpart
    "-----------------------------------------------------------------*
    TRY.
        "Complete key
        mbo_document        = zif_ca_c_wf_bos=>cbo_draw.
        mbo_document-typeid = get_delegation_type( ).
        mbo_document-instid = CONV #( ms_data-s_doc_key ).

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
  ENDMETHOD.                    "create_bo_draw


  METHOD zif_ca_archive_doc~display.
    "-----------------------------------------------------------------*
    "   Display single document
    "-----------------------------------------------------------------*
    "Local data definitions
    DATA:
      lx_error TYPE REF TO zcx_ca_archive_content,
      lv_url   TYPE saeuri.

    "Determine, if document can be displayed implace (in a container)
    is_implace_possible( ).

    IF ( mv_implace_possible EQ abap_false   AND
         iv_force_implace    EQ abap_false )  OR
         io_container        IS NOT BOUND.
      "Display DMS document
      CALL FUNCTION 'DOCUMENT_SHOW_DIRECT'   " CVAPI_DOC_VIEW ??
        EXPORTING
          dokar       = ms_data-documenttype
          doknr       = ms_data-documentnumber
          dokteil     = ms_data-documentpart
          dokvr       = ms_data-documentversion
          only_url    = abap_true
        IMPORTING
          e_url       = lv_url
        EXCEPTIONS
          not_found   = 1
          no_auth     = 2
          no_original = 3
          OTHERS      = 4.
      IF sy-subrc NE 0.
        lx_error = CAST zcx_ca_archive_content(
                             zcx_ca_error=>create_exception(
                                       iv_excp_cls = zcx_ca_archive_content=>c_zcx_ca_archive_content
                                       iv_function = 'DOCUMENT_SHOW_DIRECT'
                                       iv_subrc    = sy-subrc ) )  ##no_text.
        IF lx_error IS BOUND.
          RAISE EXCEPTION lx_error.
        ENDIF.
      ENDIF.

      CALL FUNCTION 'CALL_BROWSER'
        EXPORTING
          url                    = lv_url
        EXCEPTIONS
          frontend_not_supported = 1                " Frontend Not Supported
          frontend_error         = 2                " Error occurred in SAPGUI
          prog_not_found         = 3                " Program not found or not in executable form
          no_batch               = 4                " Front-End Function Cannot Be Executed in Backgrnd
          unspecified_error      = 5                " Unspecified Exception
          OTHERS                 = 6.
      IF sy-subrc NE 0.
        lx_error = CAST zcx_ca_archive_content(
                             zcx_ca_error=>create_exception(
                                       iv_excp_cls = zcx_ca_archive_content=>c_zcx_ca_archive_content
                                       iv_function = 'CALL_BROWSER'
                                       iv_subrc    = sy-subrc ) )  ##no_text.
        IF lx_error IS BOUND.
          RAISE EXCEPTION lx_error.
        ENDIF.
      ENDIF.


    ELSE.
      "Display in viewer implace
      open_in_viewer( io_container = io_container
                      iv_url_add   = iv_url_add ).
    ENDIF.
  ENDMETHOD.                    "zif_ca_archive_doc~display


  METHOD get_active_version.
    "-----------------------------------------------------------------*
    "   Get active document version
    "-----------------------------------------------------------------*
    "Local data definitions
    DATA:
      ls_return     TYPE bapiret2.

    "Check if document is already created and return if it is valid today
    CALL FUNCTION 'BAPI_DOCUMENT_GETACTVERSION'
      EXPORTING
        documenttype   = ms_data-s_doc_key-documenttype
        documentnumber = ms_data-s_doc_key-documentnumber
        documentpart   = ms_data-s_doc_key-documentpart
      IMPORTING
        return         = ls_return        " BAPI Return
        actualversion  = result.

    DATA(lx_error) =
         CAST zcx_ca_archive_content(
                zcx_ca_error=>create_exception(
                         iv_excp_cls = zcx_ca_archive_content=>c_zcx_ca_archive_content
                         iv_function = 'BAPI_DOCUMENT_GETACTVERSION'
                         is_return   = ls_return ) )  ##no_text.
    IF lx_error IS BOUND.
      RAISE EXCEPTION lx_error.
    ENDIF.
  ENDMETHOD.                    "get_active_version


  METHOD zif_ca_archive_doc~get_document.
    "-----------------------------------------------------------------*
    "   Get document in binary format
    "-----------------------------------------------------------------*
    "Currently not supported
    RAISE EXCEPTION TYPE zcx_ca_archive_content.
*    "Local data definitions
*    DATA:
*      lx_error    TYPE REF TO zcx_ca_archive_content,
*      lt_cont_bin TYPE sdokcntbins,
*      lt_acc_info TYPE STANDARD TABLE OF scms_acinf.
*
*    IF mv_doc IS NOT INITIAL.
*      rv_doc = mv_doc.
*
*    ELSE.
*      CALL FUNCTION 'SCMS_DOC_READ'
*        EXPORTING
*          mandt                 = mv_mandt
*          stor_cat              = ms_data-storage_cat
*          crep_id               = ms_data-archiv_id
*          doc_id                = ms_data-arc_doc_id
*        TABLES
*          access_info           = lt_acc_info
*          content_bin           = lt_cont_bin
*        EXCEPTIONS
*          bad_storage_type      = 1                " Storage Category Not Supported
*          bad_request           = 2                " Unknown Functions or Parameters
*          unauthorized          = 3                " Security Breach
*          comp_not_found        = 4                " Document/ Component/ Content Repository Not Found
*          not_found             = 5                " Document/ Component/ Content Repository Not Found
*          forbidden             = 6                " Document or Component Already Exists
*          conflict              = 7                " Document/ Component/ Administration Data is Inaccessible
*          internal_server_error = 8                " Internal Error in Content Server
*          error_http            = 9                " Error in HTTP Access
*          error_signature       = 10               " Error when Calculating Signature
*          error_config          = 11               " Configuration error
*          error_format          = 12               " Incorrect Data Format (Structure Repository)
*          error_parameter       = 13               " Parameter error
*          error                 = 14               " Unspecified error
*          OTHERS                = 15.
*      IF sy-subrc NE 0.
*        lx_error = CAST zcx_ca_archive_content(
*                             zcx_ca_error=>create_exception(
*                                       iv_excp_cls = zcx_ca_archive_content=>c_zcx_ca_archive_content
*                                       iv_function = 'SCMS_DOC_READ'
*                                       iv_subrc    = sy-subrc ) )  ##no_text.
*
*        "Send a not so technical message leaving the details in previous
*        "An error occurred while reading the document from the archive
*        RAISE EXCEPTION TYPE zcx_ca_archive_content
*          EXPORTING
*            textid   = zcx_ca_archive_content=>reading_doc_failed
*            previous = lx_error
*            mv_msgty = c_msgty_e.
*      ENDIF.
*
*      "Get length from FM results
*      READ TABLE lt_acc_info INTO  DATA(ls_acc_info)
*                             INDEX 1.
*      mv_doc_len = ls_acc_info-comp_size.
*
*      "Convert table with too long lines for an attachment in a hex string
*      CALL FUNCTION 'SCMS_BINARY_TO_XSTRING'
*        EXPORTING
*          input_length = mv_doc_len
*        IMPORTING
*          buffer       = mv_doc
*        TABLES
*          binary_tab   = lt_cont_bin
*        EXCEPTIONS
*          failed       = 1
*          OTHERS       = 2.
*      IF sy-subrc NE 0.
*        lx_error = CAST zcx_ca_archive_content(
*                             zcx_ca_error=>create_exception(
*                                       iv_excp_cls = zcx_ca_archive_content=>c_zcx_ca_archive_content
*                                       iv_function = 'SCMS_BINARY_TO_XSTRING'
*                                       iv_subrc    = sy-subrc ) )  ##no_text.
*        IF lx_error IS BOUND.
*          RAISE EXCEPTION lx_error.
*        ENDIF.
*      ENDIF.
*    ENDIF.
*
*    "Cut off superfluous hex00
*    rv_doc = mv_doc = mv_doc(mv_doc_len).
  ENDMETHOD.                    "zif_ca_archive_doc~get_document


  METHOD get_doc_status_info.
    "-----------------------------------------------------------------*
    "   Get document status information
    "-----------------------------------------------------------------*
    "Local data definitions
    DATA:
      ls_return     TYPE bapiret2.

    "Get status inclusive short text in any case
    CALL FUNCTION 'BAPI_DOCUMENT_GETSTATUS'
      EXPORTING
        documenttype      = ms_data-s_doc_key-documenttype
        documentnumber    = ms_data-s_doc_key-documentnumber
        documentpart      = ms_data-s_doc_key-documentpart
        documentversion   = ms_data-s_doc_key-documentversion
      IMPORTING
        return            = ls_return
        statusintern      = ms_data-dokst
        statusextern      = ms_data-stabk
        statusdescription = ms_data-dostx.

    DATA(lx_error) =
         CAST zcx_ca_archive_content(
                zcx_ca_error=>create_exception(
                         iv_excp_cls = zcx_ca_archive_content=>c_zcx_ca_archive_content
                         iv_function = 'BAPI_DOCUMENT_GETSTATUS'
                         is_return   = ls_return ) )  ##no_text.
    IF lx_error IS BOUND.
      RAISE EXCEPTION lx_error.
    ENDIF.
  ENDMETHOD.                    "get_doc_status_info


  METHOD get_draw_data.
    "-----------------------------------------------------------------*
    "   Get DMS object data
    "-----------------------------------------------------------------*
    "Local data definitions
    DATA:
      lt_obj_links  TYPE t_bapi_doc_drad,
      lt_doc_files  TYPE t_bapi_doc_files2,
      lt_doc_descrs TYPE tb_bapi_doc_drat,
      ls_doc_descr  TYPE bapi_doc_drat,
      ls_doc_data   TYPE bapi_doc_draw2,
      ls_return     TYPE bapiret2.

    IF mv_mandt NE sy-mandt.
      RETURN.
    ENDIF.

    ms_data-s_doc_key = CONV bapi_doc_keys( ms_data-object_id ).

    "Check, whether it is an active version and returns version number
    DATA(lv_doc_vers) = get_active_version( ).

    "Set if current document is active version
    ms_data-is_activ = abap_false.
    IF ms_data-s_doc_key-documentversion EQ lv_doc_vers.
      ms_data-is_activ = abap_true.
    ENDIF.

    "Get document status information
    get_doc_status_info( ).

    "Is a released status?
    ms_data-is_released = abap_false.
    SELECT SINGLE frknz INTO  @ms_data-is_released
                        FROM  tdws
                        WHERE dokar EQ @ms_data-s_doc_key-documenttype
                          AND dokst EQ @ms_data-dokst.

    "Get document data
    CALL FUNCTION 'BAPI_DOCUMENT_GETDETAIL2'
      EXPORTING
        documenttype         = ms_data-s_doc_key-documenttype
        documentnumber       = ms_data-s_doc_key-documentnumber
        documentpart         = ms_data-s_doc_key-documentpart
        documentversion      = ms_data-s_doc_key-documentversion
        getobjectlinks       = abap_true
        getactivefiles       = abap_true
        getdocdescriptions   = abap_true
        getdocfiles          = abap_true
      IMPORTING
        return               = ls_return
        documentdata         = ls_doc_data
      TABLES
        objectlinks          = lt_obj_links
        documentdescriptions = lt_doc_descrs
        documentfiles        = lt_doc_files.

    DATA(lx_error) =
         CAST zcx_ca_archive_content(
                zcx_ca_error=>create_exception(
                         iv_excp_cls = zcx_ca_archive_content=>c_zcx_ca_archive_content
                         iv_function = 'BAPI_DOCUMENT_GETDETAIL2'
                         is_return   = ls_return ) )  ##no_text.
    IF lx_error IS BOUND.
      RAISE EXCEPTION lx_error.
    ENDIF.

    "Set data into corresponding fields
    IF ls_doc_data-description IS INITIAL.
      IF sy-langu NE 'E' ##no_text.
        READ TABLE lt_doc_descrs INTO ls_doc_descr
                                 WITH KEY language = 'E' ##no_text.

      ELSEIF sy-langu NE 'D' ##no_text.
        READ TABLE lt_doc_descrs INTO ls_doc_descr
                                 WITH KEY language = 'D' ##no_text.
      ENDIF.

      IF sy-subrc EQ 0.
        ls_doc_data-description = ls_doc_descr-description.

      ELSE.
        ls_doc_data-description = 'No description found'(ndf).
      ENDIF.
    ENDIF.

    ms_doc_type_descr-objecttext = ls_doc_data-description.
    ms_data-ar_date       = ls_doc_data-createdate.

    READ TABLE lt_doc_files ASSIGNING FIELD-SYMBOL(<ls_doc_file>)
                            INDEX 1.
    IF sy-subrc EQ 0.
      ms_data-arc_doc_id  = <ls_doc_file>-file_id.
      ms_data-storage_cat = <ls_doc_file>-storagecategory.
      ms_data-creator     = <ls_doc_file>-created_by.
      ms_data-ar_date     = <ls_doc_file>-created_at(8).
      ms_data-ar_time     = <ls_doc_file>-created_at+8(6).
      ms_data-reserve     = ms_doc_type_def-doc_type = to_upper( <ls_doc_file>-wsapplication ).

      CALL FUNCTION 'CV120_SPLIT_PATH'
        EXPORTING
          pf_path  = <ls_doc_file>-docfile
        IMPORTING
          pfx_file = ms_data-filename.

      get_doc_class_definition( ms_doc_type_def-doc_type ).
      get_doc_class_description( ).
    ENDIF.
  ENDMETHOD.                    "get_draw_data


  METHOD zif_ca_archive_doc~get_url.
    "-----------------------------------------------------------------*
    "   Get URL to display object
    "-----------------------------------------------------------------*
    "Display DMS document
    CALL FUNCTION 'DOCUMENT_SHOW_DIRECT'
      EXPORTING
        dokar       = ms_data-documenttype
        doknr       = ms_data-documentnumber
        dokteil     = ms_data-documentpart
        dokvr       = ms_data-documentversion
        datei_name  = CONV filep( ms_data-arc_doc_id )
        only_url    = abap_true
      IMPORTING
        e_url       = result
      EXCEPTIONS
        not_found   = 1
        no_auth     = 2
        no_original = 3
        OTHERS      = 4.
    IF sy-subrc NE 0.
      DATA(lx_error) = CAST zcx_ca_archive_content(
                           zcx_ca_error=>create_exception(
                                     iv_excp_cls = zcx_ca_archive_content=>c_zcx_ca_archive_content
                                     iv_function = 'DOCUMENT_SHOW_DIRECT'
                                     iv_subrc    = sy-subrc ) )  ##no_text.
      IF lx_error IS BOUND.
        RAISE EXCEPTION lx_error.
      ENDIF.
    ENDIF.


    CONCATENATE result
                iv_url_add INTO result.
  ENDMETHOD.                    "zif_ca_archive_doc~get_url


  METHOD zif_ca_archive_doc~insert.
    "-----------------------------------------------------------------*
    "   Insert a new document (= connection)
    "-----------------------------------------------------------------*
    "Currently not supported
    RAISE EXCEPTION TYPE zcx_ca_archive_content.
*    IF ms_data IS INITIAL.
*      RETURN.
*    ENDIF.
*
*    "Set document class
*    IF ms_data-reserve IS INITIAL.
*      ms_data-reserve = ms_doc_type_def-doc_type.
*    ENDIF.
*
*    "Set archive Id from connection definition
*    IF ms_data-archiv_id IS INITIAL.
*      SELECT SINGLE archiv_id INTO  @ms_data-archiv_id
*                              FROM  toaom
*                                    USING CLIENT @mv_mandt
*                              WHERE sap_object EQ @ms_data-sap_object
*                                AND ar_object  EQ @ms_data-ar_object
*                                AND ar_status  EQ @abap_true.
*      IF sy-subrc NE 0.
*        "No active link definition in table &1 for &2 &3
*        RAISE EXCEPTION TYPE zcx_ca_archive_content
*          EXPORTING
*            textid   = zcx_ca_archive_content=>no_link_def
*            mv_msgty = c_msgty_e
*            mv_msgv1 = 'TOAOM' ##no_text
*            mv_msgv2 = CONV #( ms_data-sap_object )
*            mv_msgv3 = CONV #( ms_data-ar_object ).
*      ENDIF.
*    ENDIF.
*
*    "Set date
*    IF ms_data-ar_date IS INITIAL.
*      ms_data-ar_date = sy-datlo.
*    ENDIF.
*
*    "Insert new archive connection
*    ms_data-mandt = mv_mandt.
*    cl_alink_connection=>insert(
*                            EXPORTING
*                              link   = ms_data-s_al_conn
*                            EXCEPTIONS
*                              error  = 1
*                              OTHERS = 2 ).
*    IF sy-subrc NE 0.
*      DATA(lx_error) =
*             CAST zcx_ca_archive_content(
*                         zcx_ca_error=>create_exception(
*                                     iv_excp_cls = zcx_ca_archive_content=>c_zcx_ca_archive_content
*                                     iv_class   = 'CL_ALINK_CONNECTION'
*                                     iv_method  = 'INSERT'
*                                     iv_subrc    = sy-subrc ) )  ##no_text.
*      IF lx_error IS BOUND.
*        RAISE EXCEPTION lx_error.
*      ENDIF.
*    ENDIF.
  ENDMETHOD.                    "zif_ca_archive_doc~insert

ENDCLASS.
