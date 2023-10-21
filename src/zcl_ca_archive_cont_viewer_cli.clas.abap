"! <p class="shorttext synchronized" lang="en">CA-TBX: Document Viewer: Client</p>
"!
"! <p>This class is an adapted copy of the standard class <em><strong>CL_DV_SDV</strong></em></p>
CLASS zcl_ca_archive_cont_viewer_cli DEFINITION PUBLIC
                                                CREATE PUBLIC.

* P U B L I C   S E C T I O N
  PUBLIC SECTION.
*   i n s t a n c e   a t t r i b u t e s
    DATA:
*     o b j e c t   r e f e r e n c e s
      "! <p class="shorttext synchronized" lang="en">Document Viewer - IMC Handling</p>
      mo_imc    TYPE REF TO cl_dv_imc_client READ-ONLY,
      "! <p class="shorttext synchronized" lang="en">Document Viewer - Client</p>
      mo_viewer TYPE REF TO cl_dv_viewer READ-ONLY.

*   s t a t i c   m e t h o d s
    CLASS-METHODS:
      "! <p class="shorttext synchronized" lang="en">description</p>
      "!
      "! @parameter iv_key | <p class="shorttext synchronized" lang="en"></p>
      "! @parameter iv_val | <p class="shorttext synchronized" lang="en"></p>
      "! @parameter ct_tab | <p class="shorttext synchronized" lang="en"></p>
      append_val
        IMPORTING
          iv_key TYPE csequence
          iv_val TYPE csequence
        CHANGING
          ct_tab TYPE sdvt_string_table,

      "! <p class="shorttext synchronized" lang="en">description</p>
      "!
      "! @parameter iv_force_imc    | <p class="shorttext synchronized" lang="en"></p>
      "! @parameter iv_force_no_imc | <p class="shorttext synchronized" lang="en"></p>
      "! @parameter io_parent       | <p class="shorttext synchronized" lang="en"></p>
      "! @parameter ro_viewer_cli   | <p class="shorttext synchronized" lang="en"></p>
      "! @raising   cx_dv_exception | <p class="shorttext synchronized" lang="en">Base class for Exceptions</p>
      get_singleton
        IMPORTING
          iv_force_imc         TYPE abap_bool DEFAULT abap_false
          iv_force_no_imc      TYPE abap_bool DEFAULT abap_false
          io_parent            TYPE REF TO cl_gui_container OPTIONAL
        RETURNING
          VALUE(ro_viewer_cli) TYPE REF TO zcl_ca_archive_cont_viewer_cli
        RAISING
          cx_dv_exception,

      "! <p class="shorttext synchronized" lang="en">description</p>
      "!
      "! @parameter it_tab | <p class="shorttext synchronized" lang="en"></p>
      "! @parameter iv_key | <p class="shorttext synchronized" lang="en"></p>
      "! @parameter rv_val | <p class="shorttext synchronized" lang="en"></p>
      get_val
        IMPORTING
          !it_tab       TYPE sdvt_string_table
          !iv_key       TYPE string
        RETURNING
          VALUE(rv_val) TYPE string.

*   i n s t a n c e   m e t h o d s
    METHODS:
      "! <p class="shorttext synchronized" lang="en">description</p>
      "!
      "! @parameter io_document     | <p class="shorttext synchronized" lang="en"></p>
      "! @parameter iv_window_id    | <p class="shorttext synchronized" lang="en"></p>
      "! @parameter iv_no_refresh   | <p class="shorttext synchronized" lang="en"></p>
      "! @parameter rv_index        | <p class="shorttext synchronized" lang="en"></p>
      "! @raising   cx_dv_exception | <p class="shorttext synchronized" lang="en">Base class for Exceptions</p>
      appe_doc
        IMPORTING
          io_document     TYPE REF TO if_dv_document OPTIONAL
          iv_window_id    TYPE csequence OPTIONAL
          iv_no_refresh   TYPE abap_bool DEFAULT abap_false
        RETURNING
          VALUE(rv_index) TYPE i
        RAISING
          cx_dv_exception,

      "! <p class="shorttext synchronized" lang="en">description</p>
      "!
      "! @raising   cx_dv_exception | <p class="shorttext synchronized" lang="en">Base class for Exceptions</p>
      close_all
        RAISING
          cx_dv_exception,

      "! <p class="shorttext synchronized" lang="en">description</p>
      "!
      "! @parameter iv_window_id    | <p class="shorttext synchronized" lang="en"></p>
      "! @raising   cx_dv_exception | <p class="shorttext synchronized" lang="en">Base class for Exceptions</p>
      close_window
        IMPORTING
          iv_window_id TYPE csequence OPTIONAL
        RAISING
          cx_dv_exception,

      "! <p class="shorttext synchronized" lang="en">description</p>
      "!
      "! @parameter iv_use_imc        | <p class="shorttext synchronized" lang="en"></p>
      "! @parameter io_parent         | <p class="shorttext synchronized" lang="en"></p>
      "! @parameter it_buttons        | <p class="shorttext synchronized" lang="en"></p>
      "! @parameter iv_no_toolbar     | <p class="shorttext synchronized" lang="en"></p>
      "! @parameter iv_no_gos_toolbar | <p class="shorttext synchronized" lang="en"></p>
      "! @raising   cx_dv_exception   | <p class="shorttext synchronized" lang="en">Base class for Exceptions</p>
      constructor
        IMPORTING
          iv_use_imc        TYPE abap_bool DEFAULT abap_true
          io_parent         TYPE REF TO cl_gui_container OPTIONAL
          it_buttons        TYPE ttb_button OPTIONAL
          iv_no_toolbar     TYPE abap_bool DEFAULT abap_false
          iv_no_gos_toolbar TYPE abap_bool DEFAULT abap_false
        RAISING
          cx_dv_exception,

      "! <p class="shorttext synchronized" lang="en">description</p>
      "!
      "! @parameter io_document     | <p class="shorttext synchronized" lang="en"></p>
      "! @parameter iv_window_id    | <p class="shorttext synchronized" lang="en"></p>
      "! @parameter rv_index        | <p class="shorttext synchronized" lang="en"></p>
      "! @raising   cx_dv_exception | <p class="shorttext synchronized" lang="en">Base class for Exceptions</p>
      disp_doc
        IMPORTING
          io_document     TYPE REF TO if_dv_document OPTIONAL
          iv_window_id    TYPE csequence OPTIONAL
        RETURNING
          VALUE(rv_index) TYPE i
        RAISING
          cx_dv_exception,

      on_viewer_document_changed
        FOR EVENT document_changed OF cl_dv_viewer
        IMPORTING
          document
          window_id,

      on_viewer_document_closed
        FOR EVENT document_closed OF cl_dv_viewer
        IMPORTING
          document
          window_id,

      on_viewer_function_selected
        FOR EVENT function_selected OF cl_dv_viewer
        IMPORTING
          fcode.


* P R O T E C T E D   S E C T I O N
  PROTECTED SECTION.


* P R I V A T E   S E C T I O N
  PRIVATE SECTION.
*   s t a t i c   a t t r i b u t e s
    CLASS-DATA:
*     o b j e c t   r e f e r e n c e s
      "! <p class="shorttext synchronized" lang="en">Common object: Document Viewer - Client (copy of CL_DV_SDV)</p>
      mo_singleton_imc    TYPE REF TO zcl_ca_archive_cont_viewer_cli,
      "! <p class="shorttext synchronized" lang="en">Common object: Document Viewer - Client (copy of CL_DV_SDV)</p>
      mo_singleton_no_imc TYPE REF TO zcl_ca_archive_cont_viewer_cli.

*   s t a t i c   m e t h o d s
    CLASS-METHODS:
      "! <p class="shorttext synchronized" lang="en"></p>
      "!
      "! @parameter io_ref  | <p class="shorttext synchronized" lang="en"></p>
      "! @parameter rv_name | <p class="shorttext synchronized" lang="en"></p>
      get_class_name
        IMPORTING
          io_ref         TYPE REF TO object
        RETURNING
          VALUE(rv_name) TYPE abap_abstypename.

*   i n s t a n c e   m e t h o d s
    METHODS:
      "! <p class="shorttext synchronized" lang="en">description</p>
      "!
      "! @parameter iv_request       | <p class="shorttext synchronized" lang="en"></p>
      "! @parameter iv_do_not_create | <p class="shorttext synchronized" lang="en"></p>
      "! @raising   cx_dv_exception  | <p class="shorttext synchronized" lang="en">Base class for Exceptions</p>
      process_command
        IMPORTING
          iv_request       TYPE csequence
          iv_do_not_create TYPE abap_bool OPTIONAL
        RETURNING
          VALUE(rv_result) TYPE string
        RAISING
          cx_dv_exception.
ENDCLASS.



CLASS ZCL_CA_ARCHIVE_CONT_VIEWER_CLI IMPLEMENTATION.


  METHOD append_val.
    "-----------------------------------------------------------------*
    "   description
    "-----------------------------------------------------------------*
    "Local data definitions
    DATA:
      lv_key TYPE string,
      lv_val TYPE string.

    IF iv_val IS NOT INITIAL.
      lv_key = iv_key.
      lv_val = iv_val.
      APPEND lv_key TO ct_tab.
      APPEND lv_val TO ct_tab.
    ENDIF.
  ENDMETHOD.                    "append_val


  METHOD appe_doc.
    "-----------------------------------------------------------------*
    "   description
    "-----------------------------------------------------------------*
    "Local data definitions
    DATA:
      lr_ref        TYPE REF TO if_dv_serialize,
      lt_tab        TYPE sdvt_string_table,
      lt_result_tab TYPE sdvt_string_table,
      lv_result     TYPE string,
      lv_class      TYPE abap_abstypename,
      lv_id         TYPE string,
      lv_cmd        TYPE string.

    lr_ref ?= io_document.
    lv_id = lr_ref->serialize( ).
    lv_class = get_class_name( io_document ).

    APPEND 'APPE_DOC' TO lt_tab ##no_text.
    append_val(
          EXPORTING
            iv_key = 'CL' ##no_text
            iv_val = lv_class
          CHANGING
            ct_tab = lt_tab ).
    append_val(
          EXPORTING
            iv_key = 'ID' ##no_text
            iv_val = lv_id
          CHANGING
            ct_tab = lt_tab ).
    append_val(
          EXPORTING
            iv_key = 'WINDOW_ID' ##no_text
            iv_val = iv_window_id
          CHANGING
            ct_tab = lt_tab  ).
    append_val(
          EXPORTING
            iv_key = 'NO_REFRESH' ##no_text
            iv_val = iv_no_refresh
          CHANGING
            ct_tab = lt_tab  ).

    lv_cmd = cl_dv_utilities=>pack_string_table( lt_tab ).
    lv_result = process_command( lv_cmd ).
    lt_result_tab = cl_dv_utilities=>unpack_string_table( lv_result ).

    rv_index = get_val( iv_key = 'INDEX' ##no_text
                        it_tab = lt_result_tab ).
  ENDMETHOD.                    "appe_doc


  METHOD close_all.
    "-----------------------------------------------------------------*
    "   description
    "-----------------------------------------------------------------*
    "Local data definitions
    DATA:
      tab        TYPE sdvt_string_table,
      cmd        TYPE string,
      result     TYPE string,
      result_tab TYPE sdvt_string_table.

    APPEND 'CLOSE_ALL' TO tab ##no_text.

    cmd = cl_dv_utilities=>pack_string_table( tab ).
    result = process_command( iv_request = cmd
                              iv_do_not_create = abap_true ).
    result_tab = cl_dv_utilities=>unpack_string_table( result ).
  ENDMETHOD.                    "close_all


  METHOD close_window.
    "-----------------------------------------------------------------*
    "   description
    "-----------------------------------------------------------------*
    "Local data definitions
    DATA:
      lt_tab        TYPE sdvt_string_table,
      lt_result_tab TYPE sdvt_string_table,
      lv_result     TYPE string,
      lv_cmd        TYPE string.

    APPEND 'CLOSE_WIN' TO lt_tab ##no_text.
    append_val(
         EXPORTING
           iv_key = 'WINDOW_ID'  ##no_text
           iv_val = iv_window_id
         CHANGING
           ct_tab = lt_tab  ).

    lv_cmd = cl_dv_utilities=>pack_string_table( lt_tab ).
    lv_result = process_command( iv_request       = lv_cmd
                                 iv_do_not_create = abap_true ).
    lt_result_tab = cl_dv_utilities=>unpack_string_table( lv_result ).
  ENDMETHOD.                    "close_window


  METHOD constructor.
    "-----------------------------------------------------------------*
    "   description
    "-----------------------------------------------------------------*
    IF iv_use_imc EQ abap_true.
      CREATE OBJECT mo_imc
        EXPORTING
          name  = 'SDV'
          tcode = 'SDV' ##no_text.

    ELSE.
      CREATE OBJECT mo_viewer
        EXPORTING
          parent          = io_parent
          serve_imc       = abap_false
          toolbar_buttons = it_buttons
          no_toolbar      = iv_no_toolbar
          no_gos_toolbar  = iv_no_gos_toolbar.

      SET HANDLER: on_viewer_document_changed   FOR mo_viewer,
                   on_viewer_document_closed    FOR mo_viewer,
                   on_viewer_function_selected  FOR mo_viewer.
    ENDIF.
  ENDMETHOD.                    "constructor


  METHOD disp_doc.
    "-----------------------------------------------------------------*
    "   description
    "-----------------------------------------------------------------*
    "Local data definitions
    DATA:
      lo_ref        TYPE REF TO if_dv_serialize,
      lt_tab        TYPE sdvt_string_table,
      lt_result_tab TYPE sdvt_string_table,
      lv_result     TYPE string,
      lv_class      TYPE abap_abstypename,
      lv_id         TYPE string,
      lv_cmd        TYPE string.

    lo_ref ?= io_document.
    lv_id = lo_ref->serialize( ).
    lv_class = get_class_name( io_document ).


    APPEND 'DISP_DOC' TO lt_tab ##no_text.
    append_val(
          EXPORTING
            iv_key = 'CL'  ##no_text
            iv_val = lv_class
          CHANGING
            ct_tab = lt_tab ).
    append_val(
          EXPORTING
            iv_key = 'ID'  ##no_text
            iv_val = lv_id
          CHANGING
            ct_tab = lt_tab ).
    append_val(
          EXPORTING
            iv_key = 'WINDOW_ID'  ##no_text
            iv_val = iv_window_id
          CHANGING
            ct_tab = lt_tab  ).

    lv_cmd        = cl_dv_utilities=>pack_string_table( lt_tab ).
    lv_result     = process_command( lv_cmd ).
    lt_result_tab = cl_dv_utilities=>unpack_string_table( lv_result ).

    rv_index = get_val( iv_key = 'INDEX' ##no_text
                        it_tab = lt_result_tab ).
  ENDMETHOD.                    "disp_doc


  METHOD get_class_name.
    "-----------------------------------------------------------------*
    "   description
    "-----------------------------------------------------------------*
    rv_name = cl_abap_classdescr=>get_class_name( p_object = io_ref ).
  ENDMETHOD.                    "get_class_name


  METHOD get_singleton.
    "-----------------------------------------------------------------*
    "   description
    "-----------------------------------------------------------------*
    "Local data definitions
    DATA:
      lv_dialogbox TYPE abap_bool,
      lv_use_imc   TYPE abap_bool.

    PERFORM check_if_dialogbox
                    IN PROGRAM saplalink_display_document
                         USING lv_dialogbox.

    IF iv_force_imc EQ abap_true.
      lv_use_imc = abap_true.
    ELSEIF iv_force_no_imc EQ abap_true.
      lv_use_imc = abap_true.
    ELSE.
      IF lv_dialogbox EQ abap_true.
        lv_use_imc = abap_false.
      ELSE.
        lv_use_imc = abap_true.
      ENDIF.
    ENDIF.

    IF lv_use_imc EQ abap_true.
      IF mo_singleton_imc IS INITIAL.
        CREATE OBJECT mo_singleton_imc
          EXPORTING
            iv_use_imc = abap_true
            io_parent  = io_parent.
      ENDIF.
      ro_viewer_cli = mo_singleton_imc.

    ELSE.
      IF mo_singleton_no_imc IS INITIAL.
        CREATE OBJECT mo_singleton_no_imc
          EXPORTING
            iv_use_imc = abap_false
            io_parent  = io_parent.
      ENDIF.
      ro_viewer_cli = mo_singleton_no_imc.
    ENDIF.
  ENDMETHOD.                    "get_singleton


  METHOD get_val.
    "-----------------------------------------------------------------*
    "   description
    "-----------------------------------------------------------------*
    "Local data definitions
    DATA:
      lv_o TYPE i,
      lv_s TYPE string,
      lv_k TYPE string.

    LOOP AT it_tab INTO lv_s.
      lv_o = sy-tabix MOD 2.
      IF lv_o EQ 1.
        IF lv_k EQ iv_key.
          rv_val = lv_s.
          EXIT.
        ENDIF.
      ELSE.
        lv_k = lv_s.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.                    "get_val


  METHOD on_viewer_document_changed ##needed.

  ENDMETHOD.


  METHOD on_viewer_document_closed ##needed.

  ENDMETHOD.


  METHOD on_viewer_function_selected ##needed.

  ENDMETHOD.


  METHOD process_command.
    "-----------------------------------------------------------------*
    "   description
    "-----------------------------------------------------------------*
    IF mo_imc IS INITIAL.
      rv_result = mo_viewer->process_command( iv_request ).

    ELSE.
      mo_imc->send_command(
                           EXPORTING
                             command       = iv_request
                             code          = 'IMC'  ##no_text
                             do_not_create = iv_do_not_create
                           RECEIVING
                             result        = rv_result
                           EXCEPTIONS
                             error         = 1
                             OTHERS        = 2 ).
      IF sy-subrc NE 0.
        cx_dv_exception=>raise_from_message( msgty = 'S' ) ##no_text.
      ENDIF.
    ENDIF.
  ENDMETHOD.                    "process_command
ENDCLASS.
