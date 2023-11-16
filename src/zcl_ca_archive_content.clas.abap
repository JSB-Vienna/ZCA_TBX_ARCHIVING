"! <p class="shorttext synchronized" lang="en">CA-TBX: ArchiveLink + DMS content of a business object</p>
CLASS zcl_ca_archive_content DEFINITION PUBLIC
                                        CREATE PROTECTED
                                        GLOBAL FRIENDS zif_ca_archive_doc.
* P U B L I C   S E C T I O N
  PUBLIC SECTION.
*   i n t e r f a c e s
    INTERFACES:
      if_alink_hitlist_callback,
*      if_alink_link,
      if_xo_const_message,
      zif_ca_workflow.            " !!! Includes IF_WORKFLOW = BI_OBJECT + BI_PERSISTENT

*   a l i a s e s
    ALIASES:
*     BI_OBJECT methods
      default_attribute_value  FOR bi_object~default_attribute_value,
      execute_default_method   FOR bi_object~execute_default_method,
      release                  FOR bi_object~release,
*     BI_PERSISTENT methods
      find_by_lpor             FOR bi_persistent~find_by_lpor,
      lpor                     FOR bi_persistent~lpor,
      refresh                  FOR bi_persistent~refresh,
*     ZIF_CA_WORKFLOW methods and attributes
      check_existence          FOR zif_ca_workflow~check_existence,
      get_task_descr           FOR zif_ca_workflow~get_task_descr,
      raise_event              FOR zif_ca_workflow~raise_event,
      mo_log                   FOR zif_ca_workflow~mo_log,
      mv_default_attr          FOR zif_ca_workflow~mv_default_attr,
*     IF_ALINK_HITLIST_CALLBACK methods
      get_subdirectory_hitlist FOR if_alink_hitlist_callback~get_subdirectory_hitlist,
      load_context_menu        FOR if_alink_hitlist_callback~load_context_menu,
      process_context_menu     FOR if_alink_hitlist_callback~process_context_menu,
      process_double_click     FOR if_alink_hitlist_callback~process_double_click.

*   i n s t a n c e   a t t r i b u t e s
    DATA:
*     o b j e c t   r e f e r e n c e s
      "! <p class="shorttext synchronized" lang="en">Document Viewer - ArchiveLink (copy of CL_DV_SDV_AO)</p>
      mo_viewer      TYPE REF TO zcl_ca_archive_cont_viewer READ-ONLY,
      "! <p class="shorttext synchronized" lang="en">Constants and value checks for archive content handler</p>
      mo_arch_filter TYPE REF TO zcl_ca_c_archive_content READ-ONLY,
      "! <p class="shorttext synchronized" lang="en">Constants and value checks for select options / range tables</p>
      mo_sel_options TYPE REF TO zcl_ca_c_sel_options READ-ONLY,

*     t a b l e s
      "! <p class="shorttext synchronized" lang="en">ArchiveLink and DMS document instances</p>
      mt_docs        TYPE zca_tt_archive_docs READ-ONLY,

*     s t r u c t u r e s
      "! <p class="shorttext synchronized" lang="en">Business Object key of archive object</p>
      ms_bo_key      TYPE sibflporb READ-ONLY,
      "! <p class="shorttext synchronized" lang="en">Business object short descriptions</p>
      ms_bo_desc     TYPE tojtt READ-ONLY,
      "! <p class="shorttext synchronized" lang="en">SAP ArchiveLink Customizing table</p>
      ms_toacu       TYPE toacu READ-ONLY,

*     s i n g l e   v a l u e s
      "! <p class="shorttext synchronized" lang="en">GUID key (subst. for MS_BO_KEY -&gt; see table ZCA_MAP_BO_GUID)</p>
      mv_key         TYPE sibfinstid READ-ONLY,
      "! <p class="shorttext synchronized" lang="en">Number of selected documents</p>
      mv_count       TYPE syst_tabix READ-ONLY.

*   s t a t i c   m e t h o d s
    CLASS-METHODS:
      "! <p class="shorttext synchronized" lang="en">Create new or get existing instance</p>
      "!
      "! <p><strong>Pass parameter IS_LPOR only if this class is used as workflow object!!</strong></p>
      "!
      "! @parameter is_lpor      | <p class="shorttext synchronized" lang="en">Business class key - technical WF key</p>
      "! @parameter is_bo_key    | <p class="shorttext synchronized" lang="en">Archive Business Object key - BOR Compatible</p>
      "! @parameter iv_mandt     | <p class="shorttext synchronized" lang="en">Client (if cross-client usage)</p>
      "! @parameter result       | <p class="shorttext synchronized" lang="en">Created instance or found in buffer</p>
      "! @raising   zcx_ca_param | <p class="shorttext synchronized" lang="en">CA-TBX exception: Parameter error (INHERIT from this excep!)</p>
      "! @raising   zcx_ca_dbacc | <p class="shorttext synchronized" lang="en">CA-TBX exception: Database access</p>
      get_instance
        IMPORTING
          is_lpor       TYPE sibflpor  OPTIONAL
          is_bo_key     TYPE sibflporb OPTIONAL
          iv_mandt      TYPE symandt   DEFAULT sy-mandt
        RETURNING
          VALUE(result) TYPE REF TO zcl_ca_archive_content
        RAISING
          zcx_ca_param
          zcx_ca_dbacc.

*   i n s t a n c e   m e t h o d s
    METHODS:
      "! <p class="shorttext synchronized" lang="en">Archive a new object</p>
      "!
      "! @parameter iv_doc_type    | <p class="shorttext synchronized" lang="en">SAP ArchiveLink: Document type</p>
      "! @parameter iv_doc_class   | <p class="shorttext synchronized" lang="en">SAP ArchiveLink: Document class</p>
      "! @parameter iv_doc         | <p class="shorttext synchronized" lang="en">Document (use FMs SCMS*XSTRING* for conversion)</p>
      "! @parameter it_doc_bin     | <p class="shorttext synchronized" lang="en">Table with raw data lines</p>
      "! @parameter it_doc_char    | <p class="shorttext synchronized" lang="en">Document content in character format</p>
      "! @parameter iv_doc_length  | <p class="shorttext synchronized" lang="en">Document length</p>
      "! @parameter iv_link_immed  | <p class="shorttext synchronized" lang="en">X = Link document immediately with object</p>
      "! @parameter iv_filename    | <p class="shorttext synchronized" lang="en">Original file name</p>
      "! @parameter iv_description | <p class="shorttext synchronized" lang="en">Description (captured by user)</p>
      "! @parameter iv_creator     | <p class="shorttext synchronized" lang="en">User Id of Creator</p>
      "! @parameter result         | <p class="shorttext synchronized" lang="en">CA-TBX: Extended archive connection incl. TOAV0</p>
      "! @raising   zcx_ca_archive_content | <p class="shorttext synchronized" lang="en">CA-TBX exception: Error while handling Archive content</p>
      archive
        IMPORTING
          iv_doc_type    TYPE saeobjart
          iv_doc_class   TYPE saedoktyp      OPTIONAL
          iv_doc         TYPE xstring        OPTIONAL
          it_doc_bin     TYPE zca_tt_tbl1024 OPTIONAL
          it_doc_char    TYPE zca_tt_docs    OPTIONAL
          iv_doc_length  TYPE i              OPTIONAL
          iv_filename    TYPE toaat-filename DEFAULT space
          iv_description TYPE toaat-descr    DEFAULT space
          iv_creator     TYPE toaat-creator  DEFAULT space
          iv_link_immed  TYPE abap_bool      DEFAULT abap_true
        RETURNING
          VALUE(result)  TYPE zca_s_toav0_ext
        RAISING
          zcx_ca_archive_content,

      "! <p class="shorttext synchronized" lang="en">Archive new document(s) via a drag'n'drop dialog</p>
      "! <p>Use this method to open a standard dialog to storage a document in an archive. Prerequisite is that
      "! your dialog offers a corresponding function.</p>
      "!
      "! <p>This key is only for late instantiating and will be ignored, if the attribute MO_ARCHIVE_CONTENT has
      "! already an instance.</p>
      "! @parameter iv_refresh             | <p class="shorttext synchronized" lang="en">X=Refresh from DB, D=Add Delta (only new), ' '=Return buffer</p>
      "! @raising   zcx_ca_archive_content | <p class="shorttext synchronized" lang="en">CA-TBX exception: Error while handling Archive content</p>
      archive_via_dnd_dialog
        IMPORTING
          iv_refresh TYPE char1 DEFAULT zcl_ca_c_archive_content=>refresh_opt-add_delta_only
        RAISING
          zcx_ca_archive_content,

      "! <p class="shorttext synchronized" lang="en">Attach docs to business object (this deletes filters!)</p>
      "!
      "! @parameter it_docs                | <p class="shorttext synchronized" lang="en">New documents (= connections)</p>
      "! @parameter iv_refresh             | <p class="shorttext synchronized" lang="en">X=Refresh from DB, D=Add Delta (only new), ' '=Return buffer</p>
      "! @raising   zcx_ca_archive_content | <p class="shorttext synchronized" lang="en">CA-TBX exception: Error while handling Archive content</p>
      attach
        IMPORTING
          it_docs    TYPE zca_tt_toav0_ext
          iv_refresh TYPE abap_bool DEFAULT zcl_ca_c_archive_content=>refresh_opt-add_delta_only
        RAISING
          zcx_ca_archive_content,

      "! <p class="shorttext synchronized" lang="en">Close windows of viewer</p>
      "!
      "! @raising   zcx_ca_archive_content | <p class="shorttext synchronized" lang="en">CA-TBX exception: Error while handling ArchiveLink content</p>
      close_windows
        RAISING
          zcx_ca_archive_content,

      "! <p class="shorttext synchronized" lang="en">Constructor</p>
      "!
      "! @parameter is_lpor      | <p class="shorttext synchronized" lang="en">Business class key - technical WF key</p>
      "! @parameter is_bo_key    | <p class="shorttext synchronized" lang="en">Archive Business Object key - BOR Compatible</p>
      "! @parameter iv_mandt     | <p class="shorttext synchronized" lang="en">Client (if cross-client usage)</p>
      "! @raising   zcx_ca_param | <p class="shorttext synchronized" lang="en">CA-TBX exception: Parameter error (INHERIT from this excep!)</p>
      "! @raising   zcx_ca_dbacc | <p class="shorttext synchronized" lang="en">CA-TBX exception: Database access</p>
      constructor
        IMPORTING
          is_lpor   TYPE sibflpor
          is_bo_key TYPE sibflporb
          iv_mandt  TYPE symandt DEFAULT sy-mandt
        RAISING
          zcx_ca_param
          zcx_ca_dbacc,

      "! <p class="shorttext synchronized" lang="en">Copy content to other business object</p>
      "!
      "! @parameter is_bo_key_target | <p class="shorttext synchronized" lang="en">Business object/class key - BOR Compatible</p>
      "! @parameter io_cont_target   | <p class="shorttext synchronized" lang="en">Target instance</p>
      "! @parameter it_docs          | <p class="shorttext synchronized" lang="en">Preselected conn. of source object - otherwise copy all</p>
      "! @parameter iv_refresh       | <p class="shorttext synchronized" lang="en">X = Refresh buffer and read from DB again</p>
      "! @raising   zcx_ca_param     | <p class="shorttext synchronized" lang="en">CA-TBX exception: Parameter error (INHERIT from this excep!)</p>
      "! @raising   zcx_ca_dbacc     | <p class="shorttext synchronized" lang="en">CA-TBX exception: Database access</p>
      copy_to_other_bo
        IMPORTING
          is_bo_key_target TYPE sibflporb OPTIONAL
          io_cont_target   TYPE REF TO zcl_ca_archive_content OPTIONAL
          it_docs          TYPE zca_tt_toav0_ext OPTIONAL
          iv_refresh       TYPE abap_bool DEFAULT zcl_ca_c_archive_content=>refresh_opt-refresh_from_db
        RAISING
          zcx_ca_param
          zcx_ca_dbacc,

      "! <p class="shorttext synchronized" lang="en">Delete connections (not the docs themself!)</p>
      "!
      "! @parameter it_docs       | <p class="shorttext synchronized" lang="en">Connections to be deleted</p>
      "! @parameter it_filter_al  | <p class="shorttext synchronized" lang="en">Filter for ArchiveLink result - selected in any case</p>
      "! @parameter is_filter_dms | <p class="shorttext synchronized" lang="en">Filter for DMS (see method documentation; use C_DMS_FILT_*)</p>
      "! @raising   zcx_ca_archive_content | <p class="shorttext synchronized" lang="en">CA-TBX exception: Error while handling Archive content</p>
      delete
        IMPORTING
          it_docs       TYPE zca_tt_toav0_ext OPTIONAL
          it_filter_al  TYPE cl_alink_connection=>toarange_d_tab OPTIONAL
          is_filter_dms TYPE zca_s_dms_filter OPTIONAL
        RAISING
          zcx_ca_archive_content,

      "! <p class="shorttext synchronized" lang="en">Display document(s)</p>
      "!
      "! <p>To reduce the toolbar of the viewer to specific buttons call method GET_VIEWER_DEFAULT_BUTTON of
      "! this class to get all buttons. Delete those you don't want to offer and pass the rest to parameter
      "! IT_BUTTONS of this method DISPLAY.</p>
      "!
      "! @parameter iv_use_singleton  | <p class="shorttext synchronized" lang="en">X = Use singleton (= SAP standard behavior)</p>
      "! @parameter iv_force_imc      | <p class="shorttext synchronized" lang="en">Open in external dynpro/mode / IO_PARENT is ignored</p>
      "! @parameter iv_force_no_imc   | <p class="shorttext synchronized" lang="en">Description</p>
      "! @parameter io_parent         | <p class="shorttext synchronized" lang="en">Parent container (for a single document only)</p>
      "! @parameter it_buttons        | <p class="shorttext synchronized" lang="en">Visible toolbar buttons (see comment to this method)</p>
      "! @parameter iv_no_toolbar     | <p class="shorttext synchronized" lang="en">X = Hide toolbar</p>
      "! @parameter iv_no_gos_toolbar | <p class="shorttext synchronized" lang="en">X = Hide GOS toolbar</p>
      "! @raising   zcx_ca_archive_content | <p class="shorttext synchronized" lang="en">CA-TBX exception: Error while handling Archive content</p>
      display
        IMPORTING
          iv_use_singleton  TYPE abap_bool  DEFAULT abap_false
          iv_force_imc      TYPE abap_bool  DEFAULT abap_false
          iv_force_no_imc   TYPE abap_bool  DEFAULT abap_false
          io_parent         TYPE REF TO cl_gui_container OPTIONAL
          it_buttons        TYPE ttb_button OPTIONAL
          iv_no_toolbar     TYPE abap_bool  DEFAULT abap_false
          iv_no_gos_toolbar TYPE abap_bool  DEFAULT abap_false
        RAISING
          zcx_ca_archive_content,

      "! <p class="shorttext synchronized" lang="en">Release doc and viewer instances</p>
      free,

      "! <p class="shorttext synchronized" lang="en">Get documents (= connections) to business object</p>
      "!
      "! <p>Hint to parameter <strong>IV_SORT_BY_TIME</strong>: The result is descending sorted by date and
      "! time anyway, but the time is normally empty for ArchiveLink connections due to the fact that it is
      "! simply not available, but for DMS documents. Activate this parameter ONLY!! if the time is absolutely
      "! necessary. Then the time is read from the archive object metadata which decreases the performance,
      "! may be immensely.</p>
      "!
      "! <p>Hint for <strong>filter usage for DMS</strong>: Fill at least table T_SEL_DRAD with the pairs of
      "! object type (DOKOB) and key (OBJKY) to get a result. Any initial or generic value is ignored, since
      "! these slow down the performance drastically. In table T_FILTER the result can be more detailed. The
      "! fields DOKOB and OBJKY here will be ignored. Please use for the field name the prepared constants
      "! MO_ARCH_FILTER-&gt;DMS_FILTER-*.</p>
      "!
      "! @parameter iv_refresh       | <p class="shorttext synchronized" lang="en">Refresh buffer (use const of MO_ARCH_FILTER-&gt;REFRESH_OPT-*)</p>
      "! @parameter iv_sort_by_time  | <p class="shorttext synchronized" lang="en">X = Order by creation time (can be much slower than normal!)</p>
      "! @parameter it_filter_al     | <p class="shorttext synchronized" lang="en">Filter for ArchiveLink (const MO_ARCH_FILTER-&gt;AL_FILTER-*)</p>
      "! @parameter is_filter_dms    | <p class="shorttext synchronized" lang="en">Filter for DMS (see documentation of this method)</p>
      "! @parameter iv_only_act_vers | <p class="shorttext synchronized" lang="en">X = Only active versions (only DMS relevant)</p>
      "! @parameter iv_only_rel_vers | <p class="shorttext synchronized" lang="en">X = Only released versions (only DMS relevant)</p>
      "! @parameter result           | <p class="shorttext synchronized" lang="en">Document instances sorted descending</p>
      "! @raising   zcx_ca_archive_content | <p class="shorttext synchronized" lang="en">CA-TBX exception: Error while handling Archive content</p>
      get
        IMPORTING
          iv_refresh       TYPE abap_bool DEFAULT zcl_ca_c_archive_content=>refresh_opt-no_refresh
          iv_sort_by_time  TYPE abap_bool DEFAULT abap_false
          it_filter_al     TYPE cl_alink_connection=>toarange_d_tab OPTIONAL
          is_filter_dms    TYPE zca_s_dms_filter OPTIONAL
          iv_only_act_vers TYPE abap_bool DEFAULT abap_true
          iv_only_rel_vers TYPE abap_bool DEFAULT abap_true
        RETURNING
          VALUE(result)    TYPE zca_tt_archive_docs
        RAISING
          zcx_ca_archive_content,

      "! <p class="shorttext synchronized" lang="en">Get default button of archive content viewer</p>
      "!
      "! <p>Delete those functions the user should not use and pass them back in method DISPLAY parameter IT_BUTTONS.</p>
      "!
      "! @parameter result | <p class="shorttext synchronized" lang="en">Button / function list</p>
      get_viewer_default_button
        RETURNING
          VALUE(result) TYPE ttb_button,

      "! <p class="shorttext synchronized" lang="en">Are already documents attached to business object</p>
      "!
      "! @parameter result | <p class="shorttext synchronized" lang="en">X = Documents exist to BO</p>
      has_content
        RETURNING
          VALUE(result) TYPE abap_bool,

      "! <p class="shorttext synchronized" lang="en">Set content, e. g. after manipulating the result in MT_DOCS</p>
      "!
      "! @parameter it_docs | <p class="shorttext synchronized" lang="en">ArchiveLink and DMS document instances</p>
      set_content
        IMPORTING
          it_docs TYPE zca_tt_archive_docs.

*   i n s t a n c e   e v e n t s
    EVENTS:
      "! <p class="shorttext synchronized" lang="en">Object created</p>
      created,

      "! <p class="shorttext synchronized" lang="en">Object changed</p>
      changed,

      "! <p class="shorttext synchronized" lang="en">One or more documents stored or deleted (check counter)</p>
      "!
      "! @parameter refresh_with_opt | <p class="shorttext synchronized" lang="en">Refresh was executed with this option -&gt; see REFRESH_OPT</p>
      "! @parameter counter_before   | <p class="shorttext synchronized" lang="en">Document counter was before refresh</p>
      "! @parameter counter_now      | <p class="shorttext synchronized" lang="en">Document counter is now after refresh</p>
      new_document_stored
        EXPORTING
          VALUE(refresh_with_opt) TYPE abap_boolean
          VALUE(counter_before)   TYPE syst_tabix
          VALUE(counter_now)      TYPE syst_tabix.


* P R O T E C T E D   S E C T I O N
  PROTECTED SECTION.
*   a l i a s e s
    ALIASES:
*     Message types
      c_msgty_e            FOR  if_xo_const_message~error,
      c_msgty_i            FOR  if_xo_const_message~info,
      c_msgty_s            FOR  if_xo_const_message~success,
      c_msgty_w            FOR  if_xo_const_message~warning.

*   c o n s t a n t s
    CONSTANTS:
      "! <p class="shorttext synchronized" lang="en">AL Filter obj for business object</p>
      c_al_filt_bo   TYPE fieldname         VALUE 'SAP_OBJECT' ##no_text,
      "! <p class="shorttext synchronized" lang="en">AL Filter obj for business object key</p>
      c_al_filt_key  TYPE fieldname         VALUE 'OBJECT_ID' ##no_text,
      "! <p class="shorttext synchronized" lang="en">DMS Filter param name for business object</p>
      c_dms_filt_bo  TYPE fieldname         VALUE 'DOKOB' ##no_text,
      "! <p class="shorttext synchronized" lang="en">DMS Filter param name for business object key</p>
      c_dms_filt_key TYPE fieldname         VALUE 'OBJKY' ##no_text.

*   i n s t a n c e   a t t r i b u t e s
    DATA:
*     t a b l e s
      "! <p class="shorttext synchronized" lang="en">AL filter values passed for method GET</p>
      mt_filter_al  TYPE cl_alink_connection=>toarange_d_tab,

*     s t r u c t u r e s
      "! <p class="shorttext synchronized" lang="en">DMS filter values passed for method GET</p>
      ms_filter_dms TYPE zca_s_dms_filter,
      "! <p class="shorttext synchronized" lang="en">Workflow Business object/class key - BOR Compatible</p>
      ms_lpor       TYPE sibflpor,

*     s i n g l e   v a l u e s
      "! <p class="shorttext synchronized" lang="en">X = Full refresh of connected documents</p>
      mv_refresh    TYPE abap_boolean,
      "! <p class="shorttext synchronized" lang="en">Instance is in use for this client (cross-client usage)</p>
      mv_mandt      TYPE symandt,
      "! <p class="shorttext synchronized" lang="en">Window ID for closing</p>
      mv_window_id  TYPE saewinid.

*   s t a t i c   m e t h o d s
    CLASS-METHODS:
      "! <p class="shorttext synchronized" lang="en">Check key values of Business Object</p>
      "!
      "! @parameter is_bo_key | <p class="shorttext synchronized" lang="en">Business object/class key - BOR Compatible</p>
      "! @raising   zcx_ca_archive_content | <p class="shorttext synchronized" lang="en">CA-TBX exception: Error while handling ArchiveLink content</p>
      check_bo_key_values
        IMPORTING
          is_bo_key TYPE sibflporb
        RAISING
          zcx_ca_archive_content.

*   i n s t a n c e   m e t h o d s
    METHODS:
      "! <p class="shorttext synchronized" lang="en">Determine binary document length</p>
      "!
      "! @parameter it_document_as_binary | <p class="shorttext synchronized" lang="en">Document in binary format</p>
      "! @parameter result                | <p class="shorttext synchronized" lang="en">Length of the document</p>
      determine_binary_doc_length
        IMPORTING
          it_document_as_binary TYPE zca_tt_tbl1024
        RETURNING
          VALUE(result)         TYPE i,

      "! <p class="shorttext synchronized" lang="en">Determine character document length</p>
      "!
      "! @parameter it_document_in_character | <p class="shorttext synchronized" lang="en">Document in character format</p>
      "! @parameter result                   | <p class="shorttext synchronized" lang="en">Length of the document</p>
      determine_character_doc_length
        IMPORTING
          it_document_in_character TYPE zca_tt_docs
        RETURNING
          VALUE(result)            TYPE i,

      "! <p class="shorttext synchronized" lang="en">Extract filter values into a range object</p>
      "!
      "! @parameter it_dms_filter_range      | <p class="shorttext synchronized" lang="en">Passed filter values</p>
      "! @parameter iv_dms_filter_field_name | <p class="shorttext synchronized" lang="en">Filter name = Column name for select</p>
      "! @parameter result                   | <p class="shorttext synchronized" lang="en">Range table</p>
      "! @raising   zcx_ca_archive_content   | <p class="shorttext synchronized" lang="en">CA-TBX exception: Error while handling Archive content</p>
      extract_from_filter
        IMPORTING
          it_dms_filter_range      TYPE cl_alink_connection=>toarange_d_tab
          iv_dms_filter_field_name TYPE fieldname
        RETURNING
          VALUE(result)            TYPE rsdsselopt_t
        RAISING
          zcx_ca_archive_content,

      "! <p class="shorttext synchronized" lang="en">Get ArchiveLink documents (= connections) to business object</p>
      "!
      "! @parameter iv_sort_by_time | <p class="shorttext synchronized" lang="en">X = Order by creation time (can be much slower than normal!)</p>
      "! @parameter it_filter_al    | <p class="shorttext synchronized" lang="en">Filter for ArchiveLink (use const C_AL_FILT_*)</p>
      "! @raising   zcx_ca_archive_content | <p class="shorttext synchronized" lang="en">CA-TBX exception: Error while handling Archive content</p>
      get_al_cont
        IMPORTING
          iv_sort_by_time TYPE abap_bool DEFAULT abap_false
          it_filter_al    TYPE cl_alink_connection=>toarange_d_tab OPTIONAL
        RAISING
          zcx_ca_archive_content,

      "! <p class="shorttext synchronized" lang="en">Determine archive Id from doc.type and SAP object</p>
      "!
      "! @parameter iv_doc_type   | <p class="shorttext synchronized" lang="en">SAP ArchiveLink: Document type</p>
      "! @parameter iv_sap_object | <p class="shorttext synchronized" lang="en">SAP ArchiveLink: Object type of business object</p>
      "! @parameter ev_doc_class  | <p class="shorttext synchronized" lang="en">SAP ArchiveLink: Document class</p>
      "! @parameter ev_archiv_id  | <p class="shorttext synchronized" lang="en">Content Repository Identification</p>
      "! @raising   zcx_ca_archive_content | <p class="shorttext synchronized" lang="en">CA-TBX exception: Error while handling Archive content</p>
      get_archive_id
        IMPORTING
          iv_doc_type   TYPE saeobjart
          iv_sap_object TYPE saeanwdid
        EXPORTING
          ev_doc_class  TYPE saedoktyp
          ev_archiv_id  TYPE saearchivi
        RAISING
          zcx_ca_archive_content,

      "! <p class="shorttext synchronized" lang="en">Get DMS documents (= connections) to business object</p>
      "!
      "! @parameter iv_sort_by_time  | <p class="shorttext synchronized" lang="en">X = Order by creation time (can be much slower than normal!)</p>
      "! @parameter is_filter_dms    | <p class="shorttext synchronized" lang="en">Filter for DMS (see method documentation; use C_DMS_FILT_*)</p>
      "! @parameter iv_only_act_vers | <p class="shorttext synchronized" lang="en">X = Only active versions (only DMS relevant)</p>
      "! @parameter iv_only_rel_vers | <p class="shorttext synchronized" lang="en">X = Only released versions (only DMS relevant)</p>
      "! @raising   zcx_ca_archive_content | <p class="shorttext synchronized" lang="en">CA-TBX exception: Error while handling Archive content</p>
      get_dms_cont
        IMPORTING
          iv_sort_by_time  TYPE abap_bool DEFAULT abap_false
          is_filter_dms    TYPE zca_s_dms_filter OPTIONAL
          iv_only_act_vers TYPE abap_bool
          iv_only_rel_vers TYPE abap_bool
        RAISING
          zcx_ca_archive_content.


* P R I V A T E   S E C T I O N
  PRIVATE SECTION.
*   l o c a l   t y p e   d e f i n i t i o n
    TYPES:
      "! <p class="shorttext synchronized" lang="en">Buffered instance</p>
      BEGIN OF ty_s_buffer,
        mandt        TYPE mandt.
        INCLUDE TYPE sibflpor  AS s_lpor   RENAMING WITH SUFFIX _lpor.     "techn. WF key
        INCLUDE TYPE sibflporb AS s_bo_key RENAMING WITH SUFFIX _bo_key.   "Business Object key
    TYPES:
        o_persistent TYPE REF TO zif_ca_workflow,
      END   OF ty_s_buffer,

      "! <p class="shorttext synchronized" lang="en">Instance buffer</p>
      ty_t_buffer TYPE HASHED TABLE OF ty_s_buffer
                                       WITH UNIQUE KEY primary_key COMPONENTS mandt  s_lpor
                                       WITH NON-UNIQUE SORTED KEY ky_bo_key
                                                       COMPONENTS mandt  s_bo_key.

*   c o n s t a n t s
    CONSTANTS:
      "! <p class="shorttext synchronized" lang="en">Type Id</p>
      c_my_typeid          TYPE sibftypeid VALUE 'ZCL_CA_ARCHIVE_CONTENT' ##no_text.

*   s t a t i c   a t t r i b u t e s
    CLASS-DATA:
*     t a b l e s
      "! <p class="shorttext synchronized" lang="en">Instance buffer</p>
      mt_buffer TYPE ty_t_buffer.

ENDCLASS.



CLASS zcl_ca_archive_content IMPLEMENTATION.

  METHOD archive.
    "-----------------------------------------------------------------*
    "   Archive a new object
    "-----------------------------------------------------------------*
    "Local data definitions
    DATA:
      lx_error              TYPE REF TO zcx_ca_archive_content,
      lt_document_as_binary TYPE zca_tt_tbl1024,
      lv_document_length    TYPE i.

    " ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! !
    " Pass only one of the parameters, either IV_DOC or IT_DOC_BIN or IT_DOC_CHAR
    " ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! !

    "Set key
    result-sap_object = ms_bo_key-typeid.
    result-object_id  = ms_bo_key-instid.

    "Determine document class and archive id
    get_archive_id(
              EXPORTING
                iv_sap_object = result-sap_object
                iv_doc_type   = iv_doc_type
              IMPORTING
                ev_doc_class  = DATA(lv_doc_class_from_customizing)
                ev_archiv_id  = result-archiv_id ).

    "Check if passed document class fits to doc.class of document type
    DATA(lv_doc_class_passed) = to_upper( iv_doc_class ).
    IF lv_doc_class_passed IS NOT INITIAL AND
       lv_doc_class_passed NE lv_doc_class_from_customizing.
      "Passed doc. class &1 does not correspond to doc.class &2 of doc.type &3
      RAISE EXCEPTION TYPE zcx_ca_archive_content
        EXPORTING
          textid   = zcx_ca_archive_content=>doctype_not_corresponding
          mv_msgty = c_msgty_e
          mv_msgv1 = CONV #( lv_doc_class_passed )
          mv_msgv2 = CONV #( lv_doc_class_from_customizing )
          mv_msgv3 = CONV #( iv_doc_type ).
    ENDIF.

    TRY.
        "Determine document length and transfer into internal table
        lv_document_length = iv_doc_length.

        "Determine document length and transfer into internal table
        IF iv_doc IS NOT INITIAL.
          "B i n a r y   s t r i n g
          cl_bcs_convert=>xstring_to_xtab(
                                    EXPORTING
                                      iv_xstring = iv_doc
                                    IMPORTING
                                      et_xtab    = lt_document_as_binary ).
          IF iv_doc_length IS INITIAL.
            lv_document_length = determine_binary_doc_length( lt_document_as_binary ).
          ENDIF.

        ELSEIF it_doc_bin IS NOT INITIAL.
          "B i n a r y   t a b l e
          lt_document_as_binary = it_doc_bin.
          IF iv_doc_length IS INITIAL.
            lv_document_length = determine_binary_doc_length( lt_document_as_binary ).
          ENDIF.

        ELSEIF it_doc_char IS NOT INITIAL.
          "Character table
          DATA(lt_document_in_character) = it_doc_char.
          IF iv_doc_length IS INITIAL.
            lv_document_length = determine_character_doc_length( lt_document_in_character ).
          ENDIF.

        ELSE.
          "At least one of the following parameters must be set: &MSGV1& &MSGV2& &MSGV3& &MSGV4&
          RAISE EXCEPTION TYPE zcx_ca_archive_content
            EXPORTING
              textid   = zcx_ca_archive_content=>at_least_one
              mv_msgty = c_msgty_e
              mv_msgv1 = 'IV_DOC'
              mv_msgv2 = 'IT_DOC_BIN'
              mv_msgv3 = 'IT_DOC_CHAR' ##no_text.
        ENDIF.

      CATCH cx_bcs INTO DATA(lx_catched).
        lx_error = CAST #( zcx_ca_error=>create_exception(
                                      iv_excp_cls = zcx_ca_archive_content=>c_zcx_ca_archive_content
                                      iv_class    = 'CL_BCS_CONVERT'
                                      iv_method   = 'XSTRING_TO_XTAB'
                                      ix_error    = lx_catched ) )  ##no_text.
        IF lx_error IS BOUND.
          RAISE EXCEPTION lx_error.
        ENDIF.
    ENDTRY.

    "Set parameters for archiving
    result-ar_object = iv_doc_type.
    result-reserve   = lv_doc_class_from_customizing.
    result-ar_date   = sy-datlo.
    result-mandt     = mv_mandt.
    result-filename  = iv_filename.
    result-descr     = iv_description.
    result-creator   = iv_creator.

    "Archiving document from internal table
    CALL FUNCTION 'ARCHIVOBJECT_CREATE_TABLE'
      EXPORTING
        archiv_id                = result-archiv_id
        document_type            = lv_doc_class_from_customizing
        length                   = CONV num12( lv_document_length )
      IMPORTING
        archiv_doc_id            = result-arc_doc_id
      TABLES
        archivobject             = lt_document_in_character
        binarchivobject          = lt_document_as_binary
      EXCEPTIONS
        error_archiv             = 1
        error_communicationtable = 2
        error_kernel             = 3
        blocked_by_policy        = 4
        OTHERS                   = 5.
    IF sy-subrc NE 0.
      lx_error = CAST #( zcx_ca_error=>create_exception(
                                           iv_excp_cls = zcx_ca_archive_content=>c_zcx_ca_archive_content
                                           iv_function = 'ARCHIVOBJECT_CREATE_TABLE'
                                           iv_subrc    = sy-subrc ) )  ##no_text.
      IF lx_error IS BOUND.
        RAISE EXCEPTION lx_error.
      ENDIF.

    ELSEIF result-arc_doc_id IS INITIAL.
      "No links passed which could be entered
      RAISE EXCEPTION TYPE zcx_ca_archive_content
        EXPORTING
          textid   = zcx_ca_archive_content=>no_links_passed
          mv_msgty = c_msgty_e.
    ENDIF.

    "Link document
    IF iv_link_immed EQ abap_true.
      "Create document instance and link to object if requested
      DATA(lo_doc) = zcl_ca_archive_doc=>get_instance( io_parent     = me
                                                       is_connection = result
                                                       iv_mandt      = mv_mandt ).
      lo_doc->insert( iv_filename    = result-filename
                      iv_description = result-descr
                      iv_creator     = result-creator ).
      INSERT lo_doc INTO  mt_docs
                    INDEX 1.

      DATA(_number_of_docs_before) = mv_count.
      mv_count += 1.
      RAISE EVENT new_document_stored
        EXPORTING
          refresh_with_opt = mo_arch_filter->refresh_opt-add_delta_only
          counter_before   = _number_of_docs_before
          counter_now      = mv_count.
    ENDIF.
  ENDMETHOD.                    "archive


  METHOD archive_via_dnd_dialog.
    "-----------------------------------------------------------------*
    "   Archive new document(s) via a drag'n'drop dialog
    "-----------------------------------------------------------------*
    CALL FUNCTION 'ALINK_APPL_STORE_BY_DND'
      EXPORTING
        objecttype                  = CONV saeanwdid( ms_bo_key-typeid )
        objectid                    = CONV saeobjid( ms_bo_key-instid )
      EXCEPTIONS
        no_active_doctypes          = 1
        no_documenttype_description = 2
        no_wfl_documenttype_given   = 3
        no_orgobject_given          = 4
        no_sapobject_given          = 5
        no_object_id_given          = 6
        OTHERS                      = 7.
    IF sy-subrc NE 0.
      RAISE EXCEPTION TYPE zcx_ca_archive_content
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

    get( iv_refresh = iv_refresh ).
  ENDMETHOD.                    "archive_via_dnd_dialog


  METHOD attach.
    "-----------------------------------------------------------------*
    "   Attach docs to business object (this deletes filters!)
    "-----------------------------------------------------------------*
    "Actualize documents of object
    get( iv_refresh = mo_arch_filter->refresh_opt-refresh_from_db ).

    "Insert new documents
    LOOP AT it_docs INTO DATA(ls_doc).
      "Archiv and document id and document type must be set
      IF ls_doc-archiv_id IS INITIAL.
        "Parameter '&1' has invalid value '&2'
        RAISE EXCEPTION TYPE zcx_ca_archive_content
          EXPORTING
            textid   = zcx_ca_archive_content=>param_invalid
            mv_msgty = c_msgty_e
            mv_msgv1 = 'SPACE'
            mv_msgv2 = 'IT_DOCS-ARCHIV_ID' ##no_text.
      ENDIF.

      IF ls_doc-arc_doc_id IS INITIAL.
        "Parameter '&1' has invalid value '&2'
        RAISE EXCEPTION TYPE zcx_ca_archive_content
          EXPORTING
            textid   = zcx_ca_archive_content=>param_invalid
            mv_msgty = c_msgty_e
            mv_msgv1 = 'SPACE'
            mv_msgv2 = 'IT_DOCS-ARC_DOC_ID' ##no_text.
      ENDIF.

      "Check it if this object is already linked
      LOOP AT mt_docs TRANSPORTING NO FIELDS
                      WHERE table_line->ms_data-archiv_id  EQ ls_doc-archiv_id
                        AND table_line->ms_data-arc_doc_id EQ ls_doc-arc_doc_id ##needed.

      ENDLOOP.
      IF sy-subrc NE 0.
        "If document wasn't found insert document to content
        "Set object and key of current instance
        ls_doc-sap_object = ms_bo_key-typeid.
        ls_doc-object_id  = ms_bo_key-instid.

        DATA(lo_doc) = zcl_ca_archive_doc=>get_instance( io_parent     = me
                                                         is_connection = ls_doc
                                                         iv_mandt      = mv_mandt ).
        lo_doc->insert( iv_filename    = ls_doc-filename
                        iv_description = ls_doc-descr
                        iv_creator     = ls_doc-creator ).

        APPEND lo_doc TO mt_docs.
      ENDIF.
    ENDLOOP.

    get( iv_refresh = iv_refresh ).
  ENDMETHOD.                    "attach


  METHOD bi_object~default_attribute_value.
    "-----------------------------------------------------------------*
    "   Returns a description and/or prepared key of the object.
    "-----------------------------------------------------------------*
    DATA(lv_formatted_key) = zcl_ca_wf_utils=>prepare_object_key_for_ouput( ms_bo_key ).
    "TEXT-ALD = Archive/DMS document to &1 &2
    mv_default_attr = condense( |{ TEXT-ald } { ms_bo_key-typeid } { lv_formatted_key }| ).
    result = REF #( mv_default_attr ).
  ENDMETHOD.                    "bi_object~default_attribute_value


  METHOD bi_object~execute_default_method.
    "-----------------------------------------------------------------*
    "   Execute default method
    "-----------------------------------------------------------------*
    TRY.
        display( iv_force_imc = abap_true ).     "Force a separate window for display

      CATCH zcx_ca_error INTO DATA(lx_catched).
        MESSAGE lx_catched TYPE c_msgty_s DISPLAY LIKE lx_catched->mv_msgty.
    ENDTRY.
  ENDMETHOD.                    "bi_object~execute_default_method


  METHOD bi_object~release.
    "-----------------------------------------------------------------*
    "   Remove instance from buffer
    "-----------------------------------------------------------------*
    DELETE mt_buffer WHERE mandt    EQ mv_mandt
                       AND s_lpor   EQ ms_lpor
                       AND s_bo_key EQ ms_bo_key.
  ENDMETHOD.                    "bi_object~release


  METHOD bi_persistent~find_by_lpor.
    "-----------------------------------------------------------------*
    "   Create business class instance
    "-----------------------------------------------------------------*
    TRY.
        result ?= zcl_ca_archive_content=>get_instance( is_lpor = CORRESPONDING #( lpor ) ).

      CATCH zcx_ca_error INTO DATA(lx_catched).
        MESSAGE lx_catched TYPE c_msgty_s DISPLAY LIKE lx_catched->mv_msgty.
    ENDTRY.
  ENDMETHOD.                    "bi_persistent~find_by_lpor


  METHOD bi_persistent~lpor.
    "-----------------------------------------------------------------*
    "   Return instance key
    "-----------------------------------------------------------------*
    result = CORRESPONDING #( ms_lpor ).
  ENDMETHOD.                    "bi_persistent~lpor


  METHOD bi_persistent~refresh.
    "-----------------------------------------------------------------*
    "   Refresh instance
    "-----------------------------------------------------------------*
    TRY.
        get( iv_refresh = abap_true ).

      CATCH zcx_ca_error INTO DATA(lx_catched).
        MESSAGE lx_catched TYPE c_msgty_s DISPLAY LIKE lx_catched->mv_msgty.
    ENDTRY.
  ENDMETHOD.                    "bi_persistent~refresh


  METHOD check_bo_key_values.
    "-----------------------------------------------------------------*
    "   Check key values of Business Object
    "-----------------------------------------------------------------*
    "Currently only classic Business objects can be linked to either ArchiveLink or DMS
    IF is_bo_key-catid NE swfco_objtype_bor.
      "Parameter '&1' has invalid value '&2'
      RAISE EXCEPTION TYPE zcx_ca_archive_content
        EXPORTING
          textid   = zcx_ca_archive_content=>param_invalid
          mv_msgty = c_msgty_e
          mv_msgv1 = 'IS_BO_KEY-CATID'
          mv_msgv2 = CONV #( is_bo_key-catid ) ##no_text.
    ENDIF.

    IF is_bo_key-instid IS INITIAL.
      "Parameter '&1' is not specified
      RAISE EXCEPTION TYPE zcx_ca_archive_content
        EXPORTING
          textid   = zcx_ca_archive_content=>param_not_supplied
          mv_msgty = c_msgty_e
          mv_msgv1 = 'IS_BO_KEY-INSTID' ##no_text.
    ENDIF.
  ENDMETHOD.                    "check_bo_key_values


  METHOD close_windows.
    "-----------------------------------------------------------------*
    "   Close windows of viewer
    "-----------------------------------------------------------------*
    TRY.
        IF mo_viewer IS BOUND.
          mo_viewer->close_all(  ).
          IF mo_viewer IS BOUND.
            mo_viewer->free( ).
            FREE mo_viewer.
          ENDIF.
        ENDIF.

      CATCH cx_dv_exception INTO DATA(lx_error).
        DATA(lx_al_err) = CAST zcx_ca_archive_content( zcx_ca_error=>create_exception(
                                                 iv_excp_cls = zcx_ca_archive_content=>c_zcx_ca_archive_content
                                                 ix_error    = lx_error ) )  ##no_text.
        IF lx_al_err IS BOUND.
          RAISE EXCEPTION lx_al_err.
        ENDIF.
    ENDTRY.
  ENDMETHOD.                    "close_windows


  METHOD constructor.
    "-----------------------------------------------------------------*
    "   Constructor
    "-----------------------------------------------------------------*
    "Check existence of client
    SELECT SINGLE 'X' INTO  @DATA(exists)
                      FROM  t000
                      WHERE mandt EQ @iv_mandt.
    IF exists EQ abap_false.
      "Parameter '&1' has invalid value '&2'
      RAISE EXCEPTION TYPE zcx_ca_archive_content
        EXPORTING
          textid   = zcx_ca_archive_content=>param_invalid
          mv_msgty = c_msgty_e
          mv_msgv1 = 'IV_MANDT'
          mv_msgv2 = CONV #( iv_mandt ) ##no_text.
    ENDIF.

    "Check key length, since archive connections can only save 50 digits
    IF strlen( is_bo_key-instid ) GT 50.
      "Key is too long (max. & characters)
      RAISE EXCEPTION TYPE zcx_ca_archive_content
        EXPORTING
          textid   = zcx_ca_archive_content=>key_too_long
          mv_msgty = c_msgty_e
          mv_msgv1 = CONV #( 50 ).
    ENDIF.

    "Check business object
    SELECT SINGLE * INTO  @DATA(ls_tojtb)
                    FROM  tojtb
                    WHERE name   EQ @is_bo_key-typeid
                      AND active EQ @abap_true.
    IF sy-subrc NE 0.
      "SAP business object &1 does not exist or is not activated
      RAISE EXCEPTION TYPE zcx_ca_archive_content
        EXPORTING
          textid   = zcx_ca_archive_content=>bo_not_exist
          mv_msgty = c_msgty_e
          mv_msgv1 = CONV #( is_bo_key-typeid ).
    ENDIF.

    "Get short descriptions
    SELECT SINGLE * INTO  @ms_bo_desc
                    FROM  tojtt
                    WHERE name     EQ @is_bo_key-typeid
                      AND language EQ @sy-langu.
    IF sy-subrc NE 0.
      "Nothing found in english -> use german, use english in any other case
      DATA(lv_langu) = SWITCH spras( sy-langu
                                       WHEN 'E' THEN 'D'
                                       ELSE 'E' ) ##no_text.
      SELECT SINGLE * INTO  @ms_bo_desc
                      FROM  tojtt
                      WHERE name     EQ @is_bo_key-typeid
                        AND language EQ @lv_langu.
      IF sy-subrc NE 0.
        ms_bo_desc-name  = is_bo_key-typeid.
        ms_bo_desc-stext = ms_bo_desc-ntext = 'No description found'(ndf).
      ENDIF.
    ENDIF.

    "Complete and keep several attributes
    mv_mandt  = iv_mandt.
    ms_lpor   = is_lpor.
    mv_key    = ms_lpor-instid.
    ms_bo_key = is_bo_key.

    "Get client specific general ArchiveLink settings
    SELECT SINGLE * INTO  @ms_toacu
                    FROM  toacu
                          USING CLIENT @mv_mandt.

    mo_arch_filter = zcl_ca_c_archive_content=>get_instance( ).
    mo_sel_options = zcl_ca_c_sel_options=>get_instance( ).
  ENDMETHOD.                    "constructor


  METHOD copy_to_other_bo.
    "-----------------------------------------------------------------*
    "   Copy content to other business object
    "-----------------------------------------------------------------*
    "Local data definitions
    DATA:
      lo_cont_target TYPE REF TO zcl_ca_archive_content,
      lt_docs        TYPE zca_tt_toav0_ext.

    IF io_cont_target IS BOUND.
      lo_cont_target = io_cont_target.

    ELSEIF is_bo_key_target IS NOT INITIAL.
      "Create instance of target business object
      lo_cont_target ?= zcl_ca_archive_content=>get_instance( is_bo_key = is_bo_key_target ).

    ELSE.
      "At least one of the following parameters must be passed: &1 &2 &3 &4
      RAISE EXCEPTION TYPE zcx_ca_archive_content
        EXPORTING
          textid   = zcx_ca_archive_content=>at_least_one
          mv_msgty = c_msgty_e
          mv_msgv1 = 'IS_BO_KEY_TARGET'
          mv_msgv2 = 'IO_CONT_TARGET' ##no_text.
    ENDIF.

    "Use passed documents ...
    IF it_docs IS NOT INITIAL.
      lt_docs = it_docs.

    ELSE.
      "... or actualize content list of current object and copy list
      get( iv_refresh = zcl_ca_c_archive_content=>refresh_opt-refresh_from_db ).
      LOOP AT mt_docs ASSIGNING FIELD-SYMBOL(<lo_doc>).
        APPEND <lo_doc>->ms_data TO lt_docs.
      ENDLOOP.
    ENDIF.

    "Attach new documents to target object
    lo_cont_target->attach( it_docs    = lt_docs
                            iv_refresh = iv_refresh ).
  ENDMETHOD.                    "copy_to_other_bo


  METHOD delete.
    "-----------------------------------------------------------------*
    "   Delete connections (not the docs themself!)
    "-----------------------------------------------------------------*
    "Local data definitions
    DATA:
      lx_error   TYPE REF TO zcx_ca_archive_content.

    IF it_docs IS NOT INITIAL.
      "Delete selected connections
      LOOP AT it_docs ASSIGNING FIELD-SYMBOL(<ls_doc>).
        cl_alink_connection=>delete(
                                EXPORTING
                                  link  = <ls_doc>-s_al_conn
                                EXCEPTIONS
                                  not_found = 1
                                  OTHERS    = 2 ).
        "Reaction only for internal errors
        IF sy-subrc GE 2.
          lx_error =
               CAST zcx_ca_archive_content(
                         zcx_ca_error=>create_exception(
                                 iv_excp_cls = zcx_ca_archive_content=>c_zcx_ca_archive_content
                                 iv_class    = 'CL_ALINK_CONNECTION'
                                 iv_method   = 'DELETE'
                                 iv_subrc    = sy-subrc ) )  ##no_text.
          IF lx_error IS BOUND.
            RAISE EXCEPTION lx_error.
          ENDIF.
        ENDIF.
      ENDLOOP.

    ELSE.
      "Delete all, if IT_FILTER is initial or filtered connections
      get( iv_refresh    = abap_true
           it_filter_al  = mt_filter_al
           is_filter_dms = ms_filter_dms ).
      LOOP AT mt_docs ASSIGNING FIELD-SYMBOL(<lo_doc>).
        cl_alink_connection=>delete(
                                EXPORTING
                                  link  = <lo_doc>->ms_data-s_al_conn
                                EXCEPTIONS
                                  not_found = 1
                                  OTHERS    = 2 ).
        "Reaction only for internal errors
        IF sy-subrc GE 2.
          lx_error =
               CAST zcx_ca_archive_content(
                         zcx_ca_error=>create_exception(
                                 iv_excp_cls = zcx_ca_archive_content=>c_zcx_ca_archive_content
                                 iv_class    = 'CL_ALINK_CONNECTION'
                                 iv_method   = 'DELETE'
                                 iv_subrc    = sy-subrc ) )  ##no_text.
          IF lx_error IS BOUND.
            RAISE EXCEPTION lx_error.
          ENDIF.
        ENDIF.
      ENDLOOP.
    ENDIF.

    "Refresh connections after deletion
    get( iv_refresh    = abap_true
         it_filter_al  = mt_filter_al
         is_filter_dms = ms_filter_dms ).
  ENDMETHOD.                    "delete


  METHOD determine_binary_doc_length.
    "-----------------------------------------------------------------*
    "   Determine binary document length
    "-----------------------------------------------------------------*
    "Local data definitions
    CONSTANTS:
      _hex_null            TYPE x LENGTH 1 VALUE '00'.

    DATA(_count_of_lines_in_bin_doc) = lines( it_document_as_binary ).
    result = ( _count_of_lines_in_bin_doc - 1 ) * 1024.

    DATA(_last_line_of_document) = it_document_as_binary[ _count_of_lines_in_bin_doc ].
    DATA(_line_length) = xstrlen( _last_line_of_document-line ).

    WHILE _last_line_of_document-line+1023(1) EQ _hex_null.
      SHIFT _last_line_of_document-line RIGHT BY 1 PLACES IN BYTE MODE.
      DATA(_counted_hex_null_at_line_end) = sy-index.
    ENDWHILE.

    result = result + ( 1024 - _counted_hex_null_at_line_end ).
  ENDMETHOD.                    "determine_binary_doc_length


  METHOD determine_character_doc_length.
    "-----------------------------------------------------------------*
    "   Determine character document length
    "-----------------------------------------------------------------*
    DATA(_count_of_lines_in_char_doc) = lines( it_document_in_character ).
    result = ( _count_of_lines_in_char_doc - 1 ) * 1024.
    "Add length of last row
    result = result + strlen( it_document_in_character[ _count_of_lines_in_char_doc ] ).
  ENDMETHOD.                    "determine_binary_doc_length


  METHOD display.
    "-----------------------------------------------------------------*
    "   Display document(s)
    "-----------------------------------------------------------------*
    "Local data definitions
    DATA:
      lt_disp_docs TYPE tab_toadi.

    TRY.
        "See documentation of data element OAFROMGUI or transaction OAG1 / field 'Doc Display as Dialog Box'
        GET PARAMETER ID 'ARCHIVELINKDIALOG' FIELD DATA(lv_external_display).

        "Create viewer
        IF io_parent IS BOUND.
          SET PARAMETER ID 'ARCHIVELINKDIALOG' FIELD 'DIALOGBOX' ##no_text.   "Open in a container
          mo_viewer = zcl_ca_archive_cont_viewer=>get_singleton( iv_use_singleton  = iv_use_singleton
                                                                 iv_force_imc      = iv_force_imc
                                                                 iv_force_no_imc   = iv_force_no_imc
                                                                 io_parent         = io_parent
                                                                 it_buttons        = it_buttons
                                                                 iv_no_toolbar     = iv_no_toolbar
                                                                 iv_no_gos_toolbar = iv_no_gos_toolbar ).

        ELSE.
          SET PARAMETER ID 'ARCHIVELINKDIALOG' FIELD 'VIEWER' ##no_text.      "Open in separate screen
          mo_viewer = zcl_ca_archive_cont_viewer=>get_singleton( iv_use_singleton  = iv_use_singleton
                                                                 iv_force_imc      = iv_force_imc
                                                                 iv_force_no_imc   = iv_force_no_imc
                                                                 it_buttons        = it_buttons
                                                                 iv_no_toolbar     = iv_no_toolbar
                                                                 iv_no_gos_toolbar = iv_no_gos_toolbar ).
        ENDIF.

        "Reset to last value of the user.
        SET PARAMETER ID 'ARCHIVELINKDIALOG' FIELD lv_external_display.

        "Create window Id from LPOR
        mv_window_id = ms_lpor-instid+10(10).
        LOOP AT mt_docs ASSIGNING FIELD-SYMBOL(<lo_doc>).
          APPEND VALUE #( adid = <lo_doc>->ms_data-arc_doc_id
                          aid  = <lo_doc>->ms_data-archiv_id
                          wid  = mv_window_id
                          wti  = COND #( WHEN <lo_doc>->ms_data-descr IS NOT INITIAL
                                           THEN <lo_doc>->ms_data-descr
                                         WHEN <lo_doc>->ms_data-filename IS NOT INITIAL
                                           THEN <lo_doc>->ms_data-filename
                                         ELSE <lo_doc>->ms_doc_type_descr-objecttext )
                          dcl  = <lo_doc>->ms_data-reserve
                          oti  = <lo_doc>->ms_data-sap_object
                          oid  = <lo_doc>->ms_data-object_id
                          dti  = <lo_doc>->ms_data-ar_object ) TO lt_disp_docs.
        ENDLOOP.

        mo_viewer->disp_ao_docs( lt_disp_docs ).

      CATCH cx_dv_exception INTO DATA(lx_error).
        DATA(lx_al_err) =
              CAST zcx_ca_archive_content(
                       zcx_ca_error=>create_exception(
                                 iv_excp_cls = zcx_ca_archive_content=>c_zcx_ca_archive_content
                                 ix_error    = lx_error ) )  ##no_text.
        IF lx_al_err IS BOUND.
          RAISE EXCEPTION lx_al_err.
        ENDIF.
    ENDTRY.
  ENDMETHOD.                    "display


  METHOD extract_from_filter.
    "------------------------------------------- ----------------------*
    "   Extract filter values into a range object
    "-----------------------------------------------------------------*
    mo_arch_filter->is_dms_filter_field_valid( iv_dms_filter_field_name ).

    LOOP AT it_dms_filter_range ASSIGNING FIELD-SYMBOL(<ls_filter_dms>)
                          WHERE name EQ iv_dms_filter_field_name.
      APPEND VALUE #( sign   = <ls_filter_dms>-dsign
                      option = <ls_filter_dms>-doption
                      low    = <ls_filter_dms>-dlow
                      high   = <ls_filter_dms>-dhigh ) TO result.
    ENDLOOP.
  ENDMETHOD.                    "extract_from_filter


  METHOD free.
    "-----------------------------------------------------------------*
    "   Release doc and viewer instances
    "-----------------------------------------------------------------*
    LOOP AT mt_docs ASSIGNING FIELD-SYMBOL(<lo_doc>).
      <lo_doc>->free( ).
    ENDLOOP.
    FREE mt_docs.
  ENDMETHOD.                    "free


  METHOD get.
    "-----------------------------------------------------------------*
    "   Get documents (= connections) to business object
    "-----------------------------------------------------------------*
    mv_refresh = iv_refresh.
    "Return documents from buffer if no refresh is requested
    IF iv_refresh    EQ abap_false    AND
       it_filter_al  EQ mt_filter_al  AND
       is_filter_dms EQ ms_filter_dms AND
       mt_docs       IS NOT INITIAL.
      result = mt_docs.

    ELSE.
      DATA(_number_of_docs_before) = mv_count.
      IF mv_refresh EQ mo_arch_filter->refresh_opt-refresh_from_db.
        free( ).
      ENDIF.

      "Get documents via ArchiveLink
      get_al_cont( iv_sort_by_time = iv_sort_by_time
                   it_filter_al    = COND #(
                                       WHEN it_filter_al IS     INITIAL AND
                                            mt_filter_al IS NOT INITIAL
                                         THEN mt_filter_al
                                         ELSE it_filter_al ) ).

      DATA(ls_filter_dms) = COND #(
                              WHEN is_filter_dms IS     INITIAL AND
                                   ms_filter_dms IS NOT INITIAL
                                THEN ms_filter_dms
                                ELSE is_filter_dms ).

      get_dms_cont( iv_sort_by_time  = iv_sort_by_time
                    is_filter_dms    = ls_filter_dms
                    iv_only_act_vers = iv_only_act_vers
                    iv_only_rel_vers = iv_only_rel_vers ).

      "Sort by archiving date and time descending
      SORT mt_docs BY table_line->ms_data-ar_date DESCENDING
                      table_line->ms_data-ar_time DESCENDING.
      mv_count = lines( mt_docs ).

      IF _number_of_docs_before NE mv_count.
        RAISE EVENT new_document_stored
          EXPORTING
            refresh_with_opt = mv_refresh
            counter_before   = _number_of_docs_before
            counter_now      = mv_count.
      ENDIF.

      "Return result to caller
      IF result IS SUPPLIED.
        result = mt_docs.
      ENDIF.
    ENDIF.
  ENDMETHOD.                    "get


  METHOD get_al_cont.
    "-----------------------------------------------------------------*
    "   Get ArchiveLink content
    "-----------------------------------------------------------------*
    "Local data definitions
    DATA:
      lo_document TYPE REF TO zif_ca_archive_doc,
      ls_conn     TYPE toav0.

    "Since this class base on a single BO the filter parameter of
    "BO name (SAP_OBJECT) and key (OBJECT_ID) have to be deleted.
    DATA(lt_filter_al) = it_filter_al.
    DELETE lt_filter_al WHERE name EQ c_al_filt_bo
                          AND name EQ c_al_filt_key.

    cl_alink_connection=>find(
                         EXPORTING
                           sap_object       = CONV #( ms_bo_key-typeid )
                           object_id        = CONV #( ms_bo_key-instid )
                           mandt            = mv_mandt
                           parameter        = lt_filter_al
                         IMPORTING
                           count            = mv_count
                           connections      = DATA(lt_conns)
                         EXCEPTIONS
                           not_found        = 1
                           error_authorithy = 2
                           error_parameter  = 3
                           OTHERS           = 4 ).
    CASE sy-subrc.
      WHEN 0 OR 1.
        "Create document instances to each connection
        LOOP AT lt_conns INTO ls_conn.
          IF mv_refresh NE mo_arch_filter->refresh_opt-refresh_from_db AND
             line_exists( mt_docs[ table_line->ms_data-archiv_id  = ls_conn-archiv_id
                                   table_line->ms_data-arc_doc_id = ls_conn-arc_doc_id ] ).
            CONTINUE.
          ENDIF.

          lo_document = zcl_ca_archive_doc=>get_instance(
                                                    io_parent       = me
                                                    is_connection   = VALUE #( s_al_conn = ls_conn )
                                                    iv_sort_by_time = iv_sort_by_time
                                                    iv_mandt        = mv_mandt ).
          APPEND lo_document TO mt_docs.
        ENDLOOP.

        "Were documents deleted or filtered?
        LOOP AT mt_docs INTO lo_document.
          IF NOT line_exists( lt_conns[ archiv_id  = lo_document->ms_data-archiv_id
                                        arc_doc_id = lo_document->ms_data-arc_doc_id ] ).
            DELETE mt_docs.
          ENDIF.
        ENDLOOP.

        "Keep filter options for comparison
        mt_filter_al = lt_filter_al.

      WHEN OTHERS.
        DATA(lx_error) =
               CAST zcx_ca_archive_content(
                       zcx_ca_error=>create_exception(
                               iv_excp_cls = zcx_ca_archive_content=>c_zcx_ca_archive_content
                               iv_class    = 'CL_ALINK_CONNECTION'
                               iv_method   = 'FIND'
                               iv_subrc    = sy-subrc ) )  ##no_text.
        IF lx_error IS BOUND.
          RAISE EXCEPTION lx_error.
        ENDIF.
    ENDCASE.
  ENDMETHOD.                    "get_al_cont


  METHOD get_archive_id.
    "-----------------------------------------------------------------*
    "   Determine archive Id from doc.type and SAP object
    "-----------------------------------------------------------------*
    "Local data definitions
    DATA:
      ls_toaom  TYPE toaom.

    CLEAR: ev_doc_class,
           ev_archiv_id.

    "Get document type definition
    SELECT SINGLE doc_type INTO  @ev_doc_class
                           FROM  toadv
                                 USING CLIENT @mv_mandt
                           WHERE ar_object EQ @iv_doc_type.
    IF sy-subrc NE 0.
      "Document type & does not exist.
      RAISE EXCEPTION TYPE zcx_ca_archive_content
        EXPORTING
          textid   = zcx_ca_archive_content=>doc_type_not_exist
          mv_msgty = c_msgty_e
          mv_msgv1 = CONV #( iv_doc_type ).
    ENDIF.

    "ATTENTION: This method is from here on a copy of subroutine GIVE_ME_THE_CONTREP
    "in program ARCHIVELINKTOAOM and is slightly adapted to be able to archive
    "client independant.
*  PERFORM give_me_the_contrep(archivelinktoaom) USING sap_object ar_object archiv_id.

    "Check, if a user contrep is set
    GET PARAMETER ID 'OAA' FIELD ev_archiv_id.

    "No user contrep
    IF ev_archiv_id EQ space.
      SELECT SINGLE * INTO  @ls_toaom
                      FROM  toaom
                            USING CLIENT @mv_mandt
                      WHERE sap_object EQ @iv_sap_object
                        AND ar_object  EQ @iv_doc_type
                        AND ar_status  EQ @abap_true.
      IF sy-subrc EQ 0.
        ev_archiv_id = ls_toaom-archiv_id.
      ENDIF.

    ELSE.
      "There is a user contrep
      SELECT * INTO  @ls_toaom
               FROM  toaom
                     USING CLIENT @mv_mandt
               WHERE sap_object EQ @iv_sap_object
                 AND ar_object  EQ @iv_doc_type
                 AND archiv_id  EQ @ev_archiv_id ##needed. "#EC CI_NOORDER

      ENDSELECT.
      "User contrep is allowed
      IF sy-subrc EQ 0.
        ev_archiv_id = ls_toaom-archiv_id.
        "User contrep is not allowed, so take the active contrep

      ELSE.
        SELECT SINGLE * INTO  @ls_toaom
                        FROM  toaom
                              USING CLIENT @mv_mandt
                        WHERE sap_object EQ @iv_sap_object
                          AND ar_object  EQ @iv_doc_type
                          AND ar_status  EQ @abap_true.
        IF sy-subrc EQ 0.
          ev_archiv_id = ls_toaom-archiv_id.
        ENDIF.
      ENDIF.
    ENDIF.

    IF ev_archiv_id IS INITIAL.
      "SAP ArchiveLink: Obj. type not assigned to storage syst.(Customizing) & &
      RAISE EXCEPTION TYPE zcx_ca_archive_content
        EXPORTING
          textid   = zcx_ca_archive_content=>doctype_no_assignm_to_arcid
          mv_msgty = c_msgty_e
          mv_msgv1 = CONV #( iv_sap_object )
          mv_msgv2 = CONV #( iv_doc_type ).
    ENDIF.
  ENDMETHOD.                    "get_archive_id


  METHOD get_dms_cont.
    "-----------------------------------------------------------------*
    "   Get DMS content
    "-----------------------------------------------------------------*
    "Local data definitions
    DATA:
      lt_dms_keys TYPE zca_tt_dms_keys,
      lra_dokar   TYPE rsdsselopt_t,
      lra_doknr   TYPE rsdsselopt_t,
      lra_dokvr   TYPE rsdsselopt_t,
      lra_doktl   TYPE rsdsselopt_t,
      lra_dokst   TYPE rsdsselopt_t.

    IF mv_mandt NE cl_abap_syst=>get_client( ).
      "DMS documents can not be read client independent!
      RAISE EXCEPTION TYPE zcx_ca_archive_content
        EXPORTING
          textid   = zcx_ca_archive_content=>can_not_read_dms_cli_indep
          mv_msgty = c_msgty_e.
    ENDIF.

    "Check object keys
    DATA(ls_filter_dms) = is_filter_dms.
    LOOP AT ls_filter_dms-t_sel_drad ASSIGNING FIELD-SYMBOL(<ls_sel_drad>).
      IF <ls_sel_drad>-objky IS INITIAL OR
         <ls_sel_drad>-dokob IS INITIAL.
        DELETE ls_filter_dms-t_sel_drad.
      ENDIF.
    ENDLOOP.

    IF ls_filter_dms-t_sel_drad IS INITIAL.
      RETURN.
    ENDIF.

    "Convert filter into ranges
    lra_dokar = extract_from_filter( it_dms_filter_range = ls_filter_dms-t_filter
                                     iv_dms_filter_field_name  = mo_arch_filter->dms_filter-doc_type ).
    lra_doknr = extract_from_filter( it_dms_filter_range = ls_filter_dms-t_filter
                                     iv_dms_filter_field_name  = mo_arch_filter->dms_filter-doc_id ).
    lra_dokvr = extract_from_filter( it_dms_filter_range = ls_filter_dms-t_filter
                                     iv_dms_filter_field_name  = mo_arch_filter->dms_filter-doc_version ).
    lra_doktl = extract_from_filter( it_dms_filter_range = ls_filter_dms-t_filter
                                     iv_dms_filter_field_name  = mo_arch_filter->dms_filter-doc_part ).
    lra_dokst = extract_from_filter( it_dms_filter_range = ls_filter_dms-t_filter
                                     iv_dms_filter_field_name  = mo_arch_filter->dms_filter-doc_state ).

    SELECT dokar AS documenttype,
           doknr AS documentnumber,
           dokvr AS documentversion,
           doktl AS documentpart,
           dokob,  objky         INTO  CORRESPONDING FIELDS OF TABLE @lt_dms_keys
                                 FROM  drad
                                       FOR ALL ENTRIES IN @ls_filter_dms-t_sel_drad
                                 WHERE dokob EQ @ls_filter_dms-t_sel_drad-dokob
                                   AND objky EQ @ls_filter_dms-t_sel_drad-objky
                                   AND dokar IN @lra_dokar
                                   AND doknr IN @lra_doknr
                                   AND dokvr IN @lra_dokvr
                                   AND doktl IN @lra_doktl.
    IF sy-subrc NE 0.
      RETURN.
    ENDIF.

    "Result table is sorted
    DELETE ADJACENT DUPLICATES FROM lt_dms_keys COMPARING ALL FIELDS.

    "Create and collect documents as requested
    DATA(lv_docs_ignored) = abap_false.
    LOOP AT lt_dms_keys ASSIGNING FIELD-SYMBOL(<ls_dms_key>).
      TRY.
          IF mv_refresh NE mo_arch_filter->refresh_opt-refresh_from_db AND
             line_exists( mt_docs[ table_line->ms_data-object_id = <ls_dms_key>-s_draw_key
                                   table_line->ms_data-dokob     = <ls_dms_key>-dokob
                                   table_line->ms_data-objky     = <ls_dms_key>-objky ] ).
            CONTINUE.
          ENDIF.

          DATA(lo_doc) =
             zcl_ca_archive_doc=>get_instance(
                                  io_parent     = me
                                  is_connection = VALUE #( sap_object = zif_ca_c_wf_bos=>cbo_draw-typeid
                                                           object_id  = <ls_dms_key>-s_draw_key
                                                           dokob      = <ls_dms_key>-dokob
                                                           objky      = <ls_dms_key>-objky ) ).

          IF lo_doc->ms_data-dokst NOT IN lra_dokst.
            CONTINUE.
          ENDIF.

          IF iv_only_act_vers         EQ abap_true  AND
             lo_doc->ms_data-is_activ EQ abap_false.
            CONTINUE.
          ENDIF.

          IF iv_only_rel_vers            EQ abap_true  AND
             lo_doc->ms_data-is_released EQ abap_false.
            CONTINUE.
          ENDIF.

          APPEND lo_doc TO mt_docs.

        CATCH zcx_ca_archive_content INTO DATA(lx_error).
          IF lx_error->mv_msgty CA zcx_ca_error=>c_msgty_eax.
            RAISE EXCEPTION lx_error.

          ELSE.
            lv_docs_ignored = abap_true.
          ENDIF.
      ENDTRY.
    ENDLOOP.

    ms_filter_dms = is_filter_dms.

    IF lv_docs_ignored EQ abap_true.
      "Due to validity or release reasons documents were ignored
      MESSAGE s065(zca_toolbox).
    ENDIF.
  ENDMETHOD.                    "get_dms_cont


  METHOD get_instance.
    "-----------------------------------------------------------------*
    "   Get instance
    "-----------------------------------------------------------------*
    "Local data definitions
    DATA:
      ls_lpor   TYPE sibflpor,     "technical WF key, carrying the name of the executed class
      ls_bo_key TYPE sibflporb.    "Key of archive BO to be handled by the class in LS_LPOR

    IF is_bo_key IS NOT INITIAL.
      check_bo_key_values( is_bo_key ).
      ls_bo_key = is_bo_key.

      ls_lpor = VALUE #( typeid = to_upper( COND #( WHEN is_lpor-typeid IS NOT INITIAL
                                                     THEN is_lpor-typeid   "use inherited type if passed
                                                     ELSE zcl_ca_archive_content=>c_my_typeid ) )
                        instid = NEW zcl_ca_map_bo_key_2_guid( )->get_guid_by_bo_key( is_bo_key )
                        catid  = swfco_objtype_cl ).

    ELSEIF is_lpor IS NOT INITIAL.
      IF is_lpor-instid IS INITIAL.
        RETURN.
      ENDIF.

      ls_bo_key  = NEW zcl_ca_map_bo_key_2_guid( )->get_bo_key_by_guid( is_lpor-instid ).
      ls_lpor = is_lpor.

    ELSE.
      "At least one of the following parameters must be passed: &1 &2 &3 &4
      RAISE EXCEPTION TYPE zcx_ca_archive_content
        EXPORTING
          textid   = zcx_ca_archive_content=>at_least_one
          mv_msgty = c_msgty_e
          mv_msgv1 = 'IS_LPOR'
          mv_msgv2 = 'IS_BO_KEY' ##no_text.
    ENDIF.

    "Is an instance already created?
    TRY.
        DATA(ls_buffer) = zcl_ca_archive_content=>mt_buffer[ KEY primary_key
                                                                 mandt  = iv_mandt
                                                                 s_lpor = ls_lpor ].
        ls_buffer-o_persistent->refresh( ).

      CATCH cx_sy_itab_line_not_found.
        TRY.
            ls_buffer = zcl_ca_archive_content=>mt_buffer[ KEY ky_bo_key
                                                               mandt    = iv_mandt
                                                               s_bo_key = ls_bo_key ].
            ls_buffer-o_persistent->refresh( ).

          CATCH cx_sy_itab_line_not_found.
            TRY.
                "Create instance of passed object type
                CREATE OBJECT ls_buffer-o_persistent TYPE (ls_lpor-typeid)
                  EXPORTING
                    is_lpor   = ls_lpor
                    is_bo_key = ls_bo_key
                    iv_mandt  = iv_mandt.

                "Checks existence of object and creates default attribute = readable key with text
                ls_buffer-o_persistent->check_existence( ).
                ls_buffer-o_persistent->default_attribute_value( ).

                ls_buffer-mandt    = iv_mandt.
                ls_buffer-s_lpor   = ls_buffer-o_persistent->lpor( ).
                ls_buffer-s_bo_key = ls_bo_key.
                INSERT ls_buffer INTO TABLE zcl_ca_archive_content=>mt_buffer.

              CATCH cx_root INTO DATA(lx_catched).
                MESSAGE lx_catched TYPE c_msgty_s DISPLAY LIKE c_msgty_e.
            ENDTRY.
        ENDTRY.
    ENDTRY.

    result ?= ls_buffer-o_persistent.
  ENDMETHOD.                    "get_instance


  METHOD get_viewer_default_button.
    "-----------------------------------------------------------------*
    "   Get default button of archive content viewer
    "-----------------------------------------------------------------*
    result = cl_dv_viewer=>get_default_toolbar_buttons( ).
  ENDMETHOD.                    "get_viewer_default_button


  METHOD has_content.
    "-----------------------------------------------------------------*
    "   Are already documents attached to business object
    "-----------------------------------------------------------------*
    result = abap_false.
    IF mt_docs IS NOT INITIAL.
      result = abap_true.
    ENDIF.
  ENDMETHOD.                    "has_content


  METHOD if_alink_hitlist_callback~get_subdirectory_hitlist  ##needed.
    "-----------------------------------------------------------------*
    "   Return Hits Behind a Sub-Directory
    "-----------------------------------------------------------------*
    "This method has no functionality and is only needed to avoid an
    "exception.
  ENDMETHOD.                    "if_alink_hitlist_callback~get_subdirectory_hitlist


  METHOD if_alink_hitlist_callback~load_context_menu  ##needed.
    "-----------------------------------------------------------------*
    "   Display Selected Documents
    "-----------------------------------------------------------------*
    "This method has no functionality and is only needed to avoid an
    "exception.
  ENDMETHOD.                    "if_alink_hitlist_callback~load_context_menu


  METHOD if_alink_hitlist_callback~process_context_menu  ##needed.
    "-----------------------------------------------------------------*
    "   Execute Function Selected From Context Menu.
    "-----------------------------------------------------------------*
  ENDMETHOD.                    "if_alink_hitlist_callback~process_context_menu


  METHOD if_alink_hitlist_callback~process_double_click  ##needed.
    "-----------------------------------------------------------------*
    "   Execute Double-Click on a Hit
    "-----------------------------------------------------------------*
  ENDMETHOD.                    "if_alink_hitlist_callback~process_double_click


  METHOD set_content.
    "-----------------------------------------------------------------*
    "   Set content, e. g. after manipulating the result in MT_DOCS
    "-----------------------------------------------------------------*
    mt_docs = it_docs.
  ENDMETHOD.                    "set_content


  METHOD zif_ca_workflow~check_existence.
    "-----------------------------------------------------------------*
    "   Check existence of object
    "-----------------------------------------------------------------*
    "Not necessary for this object, but can be redefined if wished. Use the following as a rough pattern.

*    !!  Using the BO includes mostly an existence check  !!
*    IF mo_wfmacs_BUS2012 IS BOUND.
*      mo_wfmacs_BUS2012->refresh( ).
*    ELSE.
*      "Set BUS2012 key
*      mbo_BUS2012-instid = CONV #( mv_key ).
*      mo_wfmacs_BUS2012 = NEW #( mbo_BUS2012 ).
*    ENDIF.

*    SELECT SINGLE * INTO  ms_data
*                    FROM  xxxx
*                    WHERE aaaa EQ iv_key.
*    IF sy-subrc NE 0.
*      "No entry exists for & in Table &
*      RAISE EXCEPTION TYPE zcx_ca_dbacc
*        EXPORTING
*          textid   = zcx_ca_dbacc=>no_entry
*          mv_msgty = c_msgty_e
*          mv_msgv1 = CONV #( |{ iv_key ALPHA = OUT }| )
*          mv_msgv2 = 'TABLE_NAME' ##no_text.
*    ENDIF.
  ENDMETHOD.                    "zif_ca_workflow~check_existence


  METHOD zif_ca_workflow~get_task_descr.
    "-----------------------------------------------------------------*
    "   Assemble task short text
    "-----------------------------------------------------------------*
    "Example ==> see also method BI_OBJECT~DEFAULT_ATTRIBUTE_VALUE
    "= Archive / DMS document to OOOOOOOO bbbb nnnnnnn yyyy - Description
    result = |{ mv_default_attr } - { iv_task_desc }|.

    "Use this statement in your task short description, here in this sample for a background step
*    &_WI_OBJECT_ID.GET_TASK_DESCR(IV_TASK_DESC='Post document (BG)')&
  ENDMETHOD.                    "zif_ca_workflow~get_task_descr


  METHOD zif_ca_workflow~raise_event.
    "-----------------------------------------------------------------*
    "   Raise event
    "-----------------------------------------------------------------*
    zcl_ca_wf_wapi_utils=>create_event_extended( is_lpor      = CORRESPONDING #( ms_lpor )
                                                 iv_event     = iv_event
                                                 io_evt_cnt   = io_evt_cnt
                                                 iv_do_commit = iv_do_commit ).
  ENDMETHOD.                    "zif_ca_workflow~raise_event

ENDCLASS.
