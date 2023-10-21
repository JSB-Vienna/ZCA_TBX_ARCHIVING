"! <p class="shorttext synchronized" lang="en">CA-TBX: Archive Content: ArchiveLink + DMS document</p>
CLASS zcl_ca_archive_doc DEFINITION PUBLIC
                                    CREATE PROTECTED
                                    ABSTRACT.
* P U B L I C   S E C T I O N
  PUBLIC SECTION.
*   i n t e r f a c e s
    INTERFACES:
      if_xo_const_message,
      zif_ca_archive_doc.

*   a l i a s e s
    ALIASES:
*     Variables
      cs_url_addition      FOR  zif_ca_archive_doc~cs_url_addition,
      mbo_document         FOR  zif_ca_archive_doc~mbo_document,
      ms_data              FOR  zif_ca_archive_doc~ms_data,
      ms_doc_class_def     FOR  zif_ca_archive_doc~ms_doc_class_def,
      ms_doc_class_descr   FOR  zif_ca_archive_doc~ms_doc_class_descr,
      ms_doc_type_def      FOR  zif_ca_archive_doc~ms_doc_type_def,
      ms_doc_type_descr    FOR  zif_ca_archive_doc~ms_doc_type_descr,
      mv_doc_length        FOR  zif_ca_archive_doc~mv_doc_length,
      mv_implace_possible  FOR  zif_ca_archive_doc~mv_implace_possible,
*     Methods
      delete               FOR  zif_ca_archive_doc~delete,
      display              FOR  zif_ca_archive_doc~display,
      free                 FOR  zif_ca_archive_doc~free,
      get_document         FOR  zif_ca_archive_doc~get_document,
      get_url              FOR  zif_ca_archive_doc~get_url,
      insert               FOR  zif_ca_archive_doc~insert,
      is_implace_possible  FOR  zif_ca_archive_doc~is_implace_possible.

*   s t a t i c   m e t h o d s
    CLASS-METHODS:
      "! <p class="shorttext synchronized" lang="en">Get instance of archived document</p>
      "!
      "! @parameter io_parent       | <p class="shorttext synchronized" lang="en">ArchiveLink + DMS: Archived content of a business object</p>
      "! @parameter is_connection   | <p class="shorttext synchronized" lang="en">Connection entry (= document details)</p>
      "! @parameter iv_mandt        | <p class="shorttext synchronized" lang="en">Client (if cross-client usage)</p>
      "! @parameter iv_sort_by_time | <p class="shorttext synchronized" lang="en">X = Order by creation time (can be much slower than normal!)</p>
      "! @raising   zcx_ca_archive_content | <p class="shorttext synchronized" lang="en">Common exception: Error while handling ArchiveLink content</p>
      get_instance
        IMPORTING
          io_parent       TYPE REF TO zcl_ca_archive_content
          is_connection   TYPE zca_s_toav0_ext
          iv_mandt        TYPE symandt   DEFAULT sy-mandt
          iv_sort_by_time TYPE abap_bool DEFAULT abap_false
        RETURNING
          VALUE(result)   TYPE REF TO zif_ca_archive_doc
        RAISING
          zcx_ca_archive_content.

*   i n s t a n c e   m e t h o d s
    METHODS:
      "! <p class="shorttext synchronized" lang="en">Constructor</p>
      "!
      "! @parameter io_parent     | <p class="shorttext synchronized" lang="en">ArchiveLink + DMS: Archived content of a business object</p>
      "! @parameter is_connection | <p class="shorttext synchronized" lang="en">Document (= connection entry)</p>
      "! @parameter iv_mandt      | <p class="shorttext synchronized" lang="en">Client (if cross-client usage)</p>
      "! @raising   zcx_ca_archive_content | <p class="shorttext synchronized" lang="en">Common exception: Error while handling ArchiveLink content</p>
      constructor
        IMPORTING
          io_parent     TYPE REF TO zcl_ca_archive_content
          is_connection TYPE zca_s_toav0_ext
          iv_mandt      TYPE symandt
        RAISING
          zcx_ca_archive_content.


* P R O T E C T E D   S E C T I O N
  PROTECTED SECTION.
*   a l i a s e s
    ALIASES:
*     Message types
      c_msgty_e            FOR  if_xo_const_message~error,
      c_msgty_i            FOR  if_xo_const_message~info,
      c_msgty_s            FOR  if_xo_const_message~success,
      c_msgty_w            FOR  if_xo_const_message~warning.

*   i n s t a n c e   a t t r i b u t e s
    DATA:
*     o b j e c t   r e f e r e n c e s
      "! <p class="shorttext synchronized" lang="en">ArchiveLink + DMS: Archived content of a business object</p>
      mo_parent          TYPE REF TO zcl_ca_archive_content,
      "! <p class="shorttext synchronized" lang="en">Document Viewer Interface</p>
      mo_viewer          TYPE REF TO i_oi_document_viewer,
      "! <p class="shorttext synchronized" lang="en">Macro handler for BO DRAW or IMAGE</p>
      mo_wfmacs_document TYPE REF TO zcl_ca_wf_exec_macros,

*     s i n g l e   v a l u e s
      "! <p class="shorttext synchronized" lang="en">Document in binary format</p>
      mv_doc             TYPE xstring,
      "! <p class="shorttext synchronized" lang="en">Instance is in use for this client (cross-client usage)</p>
      mv_mandt           TYPE symandt.

*   i n s t a n c e   m e t h o d s
    METHODS:
      "! <p class="shorttext synchronized" lang="en">Get BO delegation type</p>
      "!
      "! @parameter result | <p class="shorttext synchronized" lang="en">Original type or delegated type</p>
      get_delegation_type
        RETURNING
          VALUE(result) TYPE sibftypeid,

      "! <p class="shorttext synchronized" lang="en">Get document class definition</p>
      "!
      "! @parameter iv_doc_class         | <p class="shorttext synchronized" lang="en">Document class</p>
      "! @raising zcx_ca_archive_content | <p class="shorttext synchronized" lang="en">Common exception: Error while handling ArchiveLink content</p>
      get_doc_class_definition
        IMPORTING
          iv_doc_class TYPE saedoktyp
        RAISING
          zcx_ca_archive_content,

      "! <p class="shorttext synchronized" lang="en">Get document class description</p>
      get_doc_class_description,

      "! <p class="shorttext synchronized" lang="en">Open document in implace viewer (currently only for AL docs)</p>
      "!
      "! @parameter io_container | <p class="shorttext synchronized" lang="en">Parent container (e. g.custom or splitter container)</p>
      "! @parameter iv_url_add   | <p class="shorttext synchronized" lang="en">URL addition(s) - !!will be attached as passed!!</p>
      "! @raising   zcx_ca_archive_content | <p class="shorttext synchronized" lang="en">Common exception: Error while handling ArchiveLink content</p>
      open_in_viewer
        IMPORTING
          io_container TYPE REF TO cl_gui_container OPTIONAL
          iv_url_add   TYPE string OPTIONAL
        RAISING
          zcx_ca_archive_content.


* P R I V A T E   S E C T I O N
  PRIVATE SECTION.


ENDCLASS.



CLASS zcl_ca_archive_doc IMPLEMENTATION.

  METHOD constructor.
    "-----------------------------------------------------------------*
    "   Constructor
    "-----------------------------------------------------------------*
    mo_parent = io_parent.
    ms_data   = is_connection.
    mv_mandt  = iv_mandt.
  ENDMETHOD.                    "constructor


  METHOD get_delegation_type.
    "-----------------------------------------------------------------*
    "   Get BO delegation type
    "-----------------------------------------------------------------*
    SELECT SINGLE FROM   tojtd
                  FIELDS modobjtype
                  WHERE  objtype EQ @mbo_document-typeid
                  INTO   @result.
    IF sy-subrc NE 0.
      result = mbo_document-typeid.   "keep initial value
    ENDIF.
  ENDMETHOD.                    "get_delegation_type


  METHOD get_doc_class_definition.
    "-----------------------------------------------------------------*
    "   Get document class definition
    "-----------------------------------------------------------------*
    IF ms_doc_class_def IS INITIAL.
      "Get document type definition
      SELECT SINGLE * INTO  @ms_doc_class_def
                      FROM  toadd
                      WHERE doc_type EQ @iv_doc_class.
      IF sy-subrc NE 0.
        "The document class & is not valid
        RAISE EXCEPTION TYPE zcx_ca_archive_content
          EXPORTING
            textid   = zcx_ca_archive_content=>doc_class_not_exist
            mv_msgty = c_msgty_e
            mv_msgv1 = CONV #( iv_doc_class ).
      ENDIF.
    ENDIF.
  ENDMETHOD.                    "get_doc_class_definition


  METHOD get_doc_class_description.
    "-----------------------------------------------------------------*
    "   Get document class description
    "-----------------------------------------------------------------*
    IF ms_doc_class_descr IS INITIAL.
      "Get document type definition
      SELECT SINGLE * INTO  @ms_doc_class_descr
                      FROM  toasd
                      WHERE doc_type EQ @ms_doc_class_def-doc_type
                        AND language EQ @sy-langu.
      "Nothing found in login language ...
      IF sy-subrc NE 0.
        DATA(lv_langu) = SWITCH spras( sy-langu
                                         WHEN 'E' THEN 'D'
                                         ELSE 'E' ) ##no_text.
        "... try again with English or German
        SELECT SINGLE * INTO  @ms_doc_class_descr
                        FROM  toasd
                        WHERE doc_type EQ @ms_doc_class_def-doc_type
                          AND language EQ @lv_langu.
        IF sy-subrc NE 0.
          ms_doc_class_descr-doc_type   = ms_doc_class_def-doc_type.
          ms_doc_class_descr-objecttext = 'No description found'(ndf).
        ENDIF.
      ENDIF.
    ENDIF.
  ENDMETHOD.                    "get_doc_class_description


  METHOD get_instance.
    "-----------------------------------------------------------------*
    "   Get instance of archived document
    "-----------------------------------------------------------------*
    CASE is_connection-sap_object.
      WHEN zif_ca_c_wf_bos=>cbo_draw-typeid.
        result ?= NEW zcl_ca_archive_doc_dms( io_parent     = io_parent
                                              is_connection = is_connection
                                              iv_mandt      = iv_mandt ).

      WHEN OTHERS.
        result ?= NEW zcl_ca_archive_doc_arch_link( io_parent       = io_parent
                                                    is_connection   = is_connection
                                                    iv_mandt        = iv_mandt
                                                    iv_sort_by_time = iv_sort_by_time ).
    ENDCASE.
  ENDMETHOD.                    "get_instance


  METHOD open_in_viewer.
    "-----------------------------------------------------------------*
    "   Open document in implace viewer (currently only for AL docs)
    "-----------------------------------------------------------------*
    "Local data definitions
    DATA:
      lx_error        TYPE REF TO zcx_ca_archive_content.

    DATA(lv_url) = zif_ca_archive_doc~get_url( iv_url_add ).

*    CALL FUNCTION 'CALL_BROWSER'
*      EXPORTING
*        url                    = zif_ca_archive_doc~get_url( iv_url_add )
*        window_name            = ms_dt_desc-objecttext
*        new_window             = space            " Under Win32: Open a New Window
*      EXCEPTIONS
*        frontend_not_supported = 1                " Frontend Not Supported
*        frontend_error         = 2                " Error occurred in SAPGUI
*        prog_not_found         = 3                " Program not found or not in executable form
*        no_batch               = 4                " Front-End Function Cannot Be Executed in Backgrnd
*        unspecified_error      = 5                " Unspecified Exception
*        OTHERS                 = 6.
*    IF sy-subrc NE 0.
*      lx_error = CAST zcx_ca_al_cont(
*                           zCX_ca_error=>create_exception(
*                                     iv_excp_cls = zcx_ca_al_cont=>c_zcx_ca_archive_content
*                                     iv_function = 'CALL_BROWSER'
*                                     iv_subrc    = sy-subrc ) )  ##no_text.
*      IF lx_error IS BOUND.
*        RAISE EXCEPTION lx_error.
*      ENDIF.
*    ENDIF.

    c_oi_container_control_creator=>get_document_viewer(
                                  IMPORTING
                                    viewer               = mo_viewer
                                  EXCEPTIONS
                                    unsupported_platform = 1
                                    OTHERS               = 2 ).
    IF sy-subrc NE 0.
      lx_error = CAST zcx_ca_archive_content(
                           zcx_ca_error=>create_exception(
                                     iv_excp_cls = zcx_ca_archive_content=>c_zcx_ca_archive_content
                                     iv_class    = 'C_OI_CONTAINER_CONTROL_CREATOR'
                                     iv_method   = 'GET_DOCUMENT_VIEWER'
                                     iv_subrc    = sy-subrc ) )  ##no_text.
      IF lx_error IS BOUND.
        RAISE EXCEPTION lx_error.
      ENDIF.
    ENDIF.


    mo_viewer->init_viewer(
                      EXPORTING
                        parent             = io_container
                      EXCEPTIONS
                        cntl_error         = 1
                        cntl_install_error = 2
                        dp_install_error   = 3
                        dp_error           = 4
                        OTHERS             = 5 ).
    IF sy-subrc NE 0.
      lx_error = CAST zcx_ca_archive_content(
                           zcx_ca_error=>create_exception(
                                     iv_excp_cls = zcx_ca_archive_content=>c_zcx_ca_archive_content
                                     iv_class    = 'C_OI_DOCUMENT_VIEWER'
                                     iv_method   = 'INIT_VIEWER'
                                     iv_subrc    = sy-subrc ) )  ##no_text.
      IF lx_error IS BOUND.
        RAISE EXCEPTION lx_error.
      ENDIF.
    ENDIF.

    mo_viewer->view_document_from_url(
                                    EXPORTING
                                      document_url      = lv_url
                                      show_inplace      = abap_true
                                    EXCEPTIONS
                                      cntl_error        = 1
                                      not_initialized   = 2
                                      dp_error_general  = 3
                                      invalid_parameter = 4
                                      OTHERS            = 5 ).
    IF sy-subrc NE 0.
      lx_error = CAST zcx_ca_archive_content(
                           zcx_ca_error=>create_exception(
                                     iv_excp_cls = zcx_ca_archive_content=>c_zcx_ca_archive_content
                                     iv_class    = 'C_OI_DOCUMENT_VIEWER'
                                     iv_method   = 'VIEW_DOCUMENT_FROM_URL'
                                     iv_subrc    = sy-subrc ) )  ##no_text.
      IF lx_error IS BOUND.
        RAISE EXCEPTION lx_error.
      ENDIF.
    ENDIF.
  ENDMETHOD.                    "open_in_viewer


  METHOD zif_ca_archive_doc~free.
    "-----------------------------------------------------------------*
    "   Release objects
    "-----------------------------------------------------------------*
    IF mo_viewer IS BOUND.
      mo_viewer->destroy_viewer(
                            EXCEPTIONS
                              not_initialized = 1
                              free_failed     = 2
                              OTHERS          = 3 ).
      IF sy-subrc NE 0 ##needed.
        "Nothing to do
      ENDIF.
    ENDIF.
  ENDMETHOD.                    "zif_ca_archive_doc~free


  METHOD zif_ca_archive_doc~is_implace_possible.
    "-----------------------------------------------------------------*
    "   Can document be displayed in a CFW container?
    "-----------------------------------------------------------------*
    IF mv_implace_possible IS INITIAL.
      "Determine if document is displayable implace
      CLASS cl_document DEFINITION LOAD.
      DATA(ls_doc) = VALUE toadi( adid = ms_data-arc_doc_id
                                  aid  = ms_data-archiv_id
                                  dcl  = ms_doc_type_def-doc_type ).
      mv_implace_possible = abap_false.
      IF cl_document=>document_implace( ls_doc ) EQ 1.
        mv_implace_possible = abap_true.
      ENDIF.
    ENDIF.

    result = mv_implace_possible.
  ENDMETHOD.                    "zif_ca_archive_doc~is_implace_possible

ENDCLASS.
