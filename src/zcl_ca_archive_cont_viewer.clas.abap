"! <p class="shorttext synchronized" lang="en">CA-TBX: Document Viewer: ArchiveLink</p>
"!
"! <p>This class is an adapted copy of the standard class <em><strong>CL_DV_SDV_AO</strong></em></p>
CLASS zcl_ca_archive_cont_viewer DEFINITION PUBLIC
                                            CREATE PUBLIC.

* P U B L I C   S E C T I O N
  PUBLIC SECTION.
*   i n s t a n c e   a t t r i b u t e s
    DATA:
*     o b j e c t   r e f e r e n c e s
      mo_sdv TYPE REF TO zcl_ca_archive_cont_viewer_cli READ-ONLY.

*   s t a t i c   m e t h o d s
    CLASS-METHODS:
      "! <p class="shorttext synchronized" lang="en"></p>
      "!
      "! @parameter iv_use_singleton  | <p class="shorttext synchronized" lang="en">X = Use singleton (= SAP standard behavior)</p>
      "! @parameter iv_force_imc      | <p class="shorttext synchronized" lang="en"></p>
      "! @parameter iv_force_no_imc   | <p class="shorttext synchronized" lang="en"></p>
      "! @parameter io_parent         | <p class="shorttext synchronized" lang="en"></p>
      "! @parameter it_buttons        | <p class="shorttext synchronized" lang="en"></p>
      "! @parameter iv_no_toolbar     | <p class="shorttext synchronized" lang="en"></p>
      "! @parameter iv_no_gos_toolbar | <p class="shorttext synchronized" lang="en"></p>
      "! @parameter ro_viewer_cli     | <p class="shorttext synchronized" lang="en"></p>
      "! @raising   cx_dv_exception   | <p class="shorttext synchronized" lang="en">Base class for Exceptions</p>
      get_singleton
        IMPORTING
          iv_use_singleton     TYPE abap_bool DEFAULT abap_false
          iv_force_imc         TYPE abap_bool DEFAULT abap_false
          iv_force_no_imc      TYPE abap_bool DEFAULT abap_false
          io_parent            TYPE REF TO cl_gui_container OPTIONAL
          it_buttons           TYPE ttb_button OPTIONAL
          iv_no_toolbar        TYPE abap_bool DEFAULT abap_false
          iv_no_gos_toolbar    TYPE abap_bool DEFAULT abap_false
        RETURNING
          VALUE(ro_viewer_cli) TYPE REF TO zcl_ca_archive_cont_viewer
        RAISING
          cx_dv_exception.

*   i n s t a n c e   m e t h o d s
    METHODS:
      "! <p class="shorttext synchronized" lang="en"></p>
      "!
      "! @parameter iv_mandt        | <p class="shorttext synchronized" lang="en"></p>
      "! @parameter iv_arc_id       | <p class="shorttext synchronized" lang="en"></p>
      "! @parameter iv_doc_id       | <p class="shorttext synchronized" lang="en"></p>
      "! @parameter iv_object_type  | <p class="shorttext synchronized" lang="en"></p>
      "! @parameter iv_object_id    | <p class="shorttext synchronized" lang="en"></p>
      "! @parameter iv_ar_object    | <p class="shorttext synchronized" lang="en"></p>
      "! @parameter iv_title        | <p class="shorttext synchronized" lang="en"></p>
      "! @parameter iv_window_id    | <p class="shorttext synchronized" lang="en"></p>
      "! @parameter iv_no_refresh   | <p class="shorttext synchronized" lang="en"></p>
      "! @parameter rv_index        | <p class="shorttext synchronized" lang="en"></p>
      "! @raising   cx_dv_exception | <p class="shorttext synchronized" lang="en">Base class for Exceptions</p>
      appe_ao_doc
        IMPORTING
          iv_mandt        TYPE sy-mandt DEFAULT sy-mandt
          iv_arc_id       TYPE csequence
          iv_doc_id       TYPE csequence
          iv_object_type  TYPE csequence OPTIONAL
          iv_object_id    TYPE csequence OPTIONAL
          iv_ar_object    TYPE csequence OPTIONAL
          iv_title        TYPE csequence OPTIONAL
          iv_window_id    TYPE csequence OPTIONAL
          iv_no_refresh   TYPE abap_bool DEFAULT abap_false
        RETURNING
          VALUE(rv_index) TYPE i
        RAISING
          cx_dv_exception,

      "! <p class="shorttext synchronized" lang="en"></p>
      "!
      "! @raising   cx_dv_exception | <p class="shorttext synchronized" lang="en">Base class for Exceptions</p>
      close_all
        RAISING
          cx_dv_exception,

      "! <p class="shorttext synchronized" lang="en"></p>
      "!
      "! @parameter iv_window_id    | <p class="shorttext synchronized" lang="en"></p>
      "! @raising   cx_dv_exception | <p class="shorttext synchronized" lang="en">Base class for Exceptions</p>
      close_window
        IMPORTING
          iv_window_id TYPE csequence OPTIONAL
        RAISING
          cx_dv_exception,

      "! <p class="shorttext synchronized" lang="en"></p>
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

      "! <p class="shorttext synchronized" lang="en"></p>
      "!
      "! @parameter iv_mandt        | <p class="shorttext synchronized" lang="en"></p>
      "! @parameter iv_arc_id       | <p class="shorttext synchronized" lang="en"></p>
      "! @parameter iv_doc_id       | <p class="shorttext synchronized" lang="en"></p>
      "! @parameter iv_object_type  | <p class="shorttext synchronized" lang="en"></p>
      "! @parameter iv_object_id    | <p class="shorttext synchronized" lang="en"></p>
      "! @parameter iv_ar_object    | <p class="shorttext synchronized" lang="en"></p>
      "! @parameter iv_title        | <p class="shorttext synchronized" lang="en"></p>
      "! @parameter iv_window_id    | <p class="shorttext synchronized" lang="en"></p>
      "! @parameter rv_index        | <p class="shorttext synchronized" lang="en"></p>
      "! @raising   cx_dv_exception | <p class="shorttext synchronized" lang="en">Base class for Exceptions</p>
      disp_ao_doc
        IMPORTING
          iv_mandt        TYPE sy-mandt DEFAULT sy-mandt
          iv_arc_id       TYPE csequence
          iv_doc_id       TYPE csequence
          iv_object_type  TYPE csequence OPTIONAL
          iv_object_id    TYPE csequence OPTIONAL
          iv_ar_object    TYPE csequence OPTIONAL
          iv_title        TYPE csequence OPTIONAL
          iv_window_id    TYPE csequence OPTIONAL
        RETURNING
          VALUE(rv_index) TYPE i
        RAISING
          cx_dv_exception,

      "! <p class="shorttext synchronized" lang="en"></p>
      "!
      "! @parameter it_docs         | <p class="shorttext synchronized" lang="en"></p>
      "! @raising   cx_dv_exception | <p class="shorttext synchronized" lang="en">Base class for Exceptions</p>
      disp_ao_docs
        IMPORTING
          it_docs TYPE tab_toadi
        RAISING
          cx_dv_exception,

      free.


* P R O T E C T E D   S E C T I O N
  PROTECTED SECTION.


* P R I V A T E   S E C T I O N
  PRIVATE SECTION.
*   s t a t i c   a t t r i b u t e s
    CLASS-DATA:
*     o b j e c t   r e f e r e n c e s
      mo_singleton_imc    TYPE REF TO zcl_ca_archive_cont_viewer,
      mo_singleton_no_imc TYPE REF TO zcl_ca_archive_cont_viewer.

ENDCLASS.



CLASS ZCL_CA_ARCHIVE_CONT_VIEWER IMPLEMENTATION.


  METHOD appe_ao_doc.
    "-----------------------------------------------------------------*
    "   description
    "-----------------------------------------------------------------*
    "Local data definitions
    DATA:
      lv_mandt    TYPE sy-mandt,
      lo_document TYPE REF TO cl_dv_document_ao.

    IF iv_mandt IS INITIAL.
      lv_mandt = sy-mandt.
    ELSE.
      lv_mandt = iv_mandt.
    ENDIF.

    CREATE OBJECT lo_document
      EXPORTING
        mandt       = lv_mandt
        arc_id      = iv_arc_id
        doc_id      = iv_doc_id
        object_type = iv_object_type
        object_id   = iv_object_id
        ar_object   = iv_ar_object
        title       = iv_title
        no_refresh  = abap_true.

    rv_index = mo_sdv->appe_doc( io_document   = lo_document
                                 iv_window_id  = iv_window_id
                                 iv_no_refresh = iv_no_refresh ).
  ENDMETHOD.                    "appe_ao_doc


  METHOD close_all.
    "-----------------------------------------------------------------*
    "   description
    "-----------------------------------------------------------------*
    mo_sdv->close_all( ).
  ENDMETHOD.                    "close_all


  METHOD close_window.
    "-----------------------------------------------------------------*
    "   description
    "-----------------------------------------------------------------*
    mo_sdv->close_window( iv_window_id ).
  ENDMETHOD.                    "close_window


  METHOD constructor.
    "-----------------------------------------------------------------*
    "   Constructor
    "-----------------------------------------------------------------*
    CREATE OBJECT mo_sdv
      EXPORTING
        iv_use_imc        = iv_use_imc
        io_parent         = io_parent
        it_buttons        = it_buttons
        iv_no_toolbar     = iv_no_toolbar
        iv_no_gos_toolbar = iv_no_gos_toolbar.
  ENDMETHOD.                    "constructor


  METHOD disp_ao_doc.
    "-----------------------------------------------------------------*
    "   description
    "-----------------------------------------------------------------*
    "Local data definitions
    DATA:
      lo_document TYPE REF TO cl_dv_document_ao,
      lv_mandt    TYPE sy-mandt.

    IF iv_mandt IS INITIAL.
      lv_mandt = sy-mandt.
    ELSE.
      lv_mandt = iv_mandt.
    ENDIF.

    CREATE OBJECT lo_document
      EXPORTING
        mandt       = lv_mandt
        arc_id      = iv_arc_id
        doc_id      = iv_doc_id
        object_type = iv_object_type
        object_id   = iv_object_id
        ar_object   = iv_ar_object
        title       = iv_title
        no_refresh  = abap_true.

    rv_index = mo_sdv->disp_doc( io_document  = lo_document
                                 iv_window_id = iv_window_id ).
  ENDMETHOD.                    "disp_ao_doc


  METHOD disp_ao_docs.
    "-----------------------------------------------------------------*
    "   description
    "-----------------------------------------------------------------*
    "Local data definitions
    DATA:
      lv_max        TYPE i,
      lv_no_refresh TYPE abap_bool,
      ls_doc        TYPE toadi.

    DESCRIBE TABLE it_docs LINES lv_max.

    lv_no_refresh = abap_true.

    LOOP AT it_docs INTO ls_doc.
      IF sy-tabix EQ 1.
        disp_ao_doc( iv_arc_id      = ls_doc-aid
                     iv_doc_id      = ls_doc-adid
                     iv_object_type = ls_doc-oti
                     iv_object_id   = ls_doc-oid
                     iv_ar_object   = ls_doc-dti
                     iv_window_id   = ls_doc-wid
                     iv_title       = ls_doc-wti ).

      ELSE.
        IF sy-tabix EQ lv_max.
          lv_no_refresh = abap_false.
        ENDIF.
        appe_ao_doc( iv_arc_id      = ls_doc-aid
                     iv_doc_id      = ls_doc-adid
                     iv_object_type = ls_doc-oti
                     iv_object_id   = ls_doc-oid
                     iv_ar_object   = ls_doc-dti
                     iv_window_id   = ls_doc-wid
                     iv_title       = ls_doc-wti
                     iv_no_refresh  = lv_no_refresh ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.                    "disp_ao_docs


  METHOD free.
    "-----------------------------------------------------------------*
    "   description
    "-----------------------------------------------------------------*
    IF mo_sdv IS BOUND.
      TRY.
          mo_sdv->close_window( ).

        CATCH cx_dv_exception INTO DATA(lx_catched).
          MESSAGE lx_catched TYPE 'S' DISPLAY LIKE 'E'.
      ENDTRY.
    ENDIF.


    FREE: mo_singleton_imc,
          mo_singleton_no_imc,
          mo_sdv.
  ENDMETHOD.


  METHOD get_singleton.
    "-----------------------------------------------------------------*
    "   description
    "-----------------------------------------------------------------*
    "Local data definitions
    DATA:
      lv_dialogbox TYPE abap_bool,
      lv_use_imc   TYPE abap_bool.

    IF iv_force_imc EQ abap_true.
      lv_use_imc = abap_true.
    ELSEIF iv_force_no_imc EQ abap_true.
      lv_use_imc = abap_false.
    ELSE.
      PERFORM check_if_dialogbox IN PROGRAM saplalink_display_document
                                      USING lv_dialogbox.
      IF lv_dialogbox EQ abap_true.
        lv_use_imc = abap_false.
      ELSE.
        lv_use_imc = abap_true.
      ENDIF.
    ENDIF.

    IF lv_use_imc EQ abap_true.
      IF ( zcl_ca_archive_cont_viewer=>mo_singleton_imc IS INITIAL AND
           iv_use_singleton EQ abap_true ) OR
           iv_use_singleton EQ abap_false.
        CREATE OBJECT zcl_ca_archive_cont_viewer=>mo_singleton_imc
          EXPORTING
            iv_use_imc        = abap_true
            io_parent         = io_parent
            it_buttons        = it_buttons
            iv_no_toolbar     = iv_no_toolbar
            iv_no_gos_toolbar = iv_no_gos_toolbar.
      ENDIF.
      ro_viewer_cli = zcl_ca_archive_cont_viewer=>mo_singleton_imc.

    ELSE.
      IF ( zcl_ca_archive_cont_viewer=>mo_singleton_no_imc IS INITIAL AND
           iv_use_singleton EQ abap_true ) OR
           iv_use_singleton EQ abap_false.
        CREATE OBJECT zcl_ca_archive_cont_viewer=>mo_singleton_no_imc
          EXPORTING
            iv_use_imc        = abap_false
            io_parent         = io_parent
            it_buttons        = it_buttons
            iv_no_toolbar     = iv_no_toolbar
            iv_no_gos_toolbar = iv_no_gos_toolbar.
      ENDIF.
      ro_viewer_cli = zcl_ca_archive_cont_viewer=>mo_singleton_no_imc.
    ENDIF.
  ENDMETHOD.                    "get_singleton
ENDCLASS.
