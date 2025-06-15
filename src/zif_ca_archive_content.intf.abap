"! <p class="shorttext synchronized" lang="en">CA-TBX: ArchiveLink + DMS content of a business object</p>
INTERFACE zif_ca_archive_content PUBLIC.
* i n t e r f a c e s
  INTERFACES:
    if_alink_hitlist_callback,
*    if_alink_link,
    zif_ca_workflow.            " !!! Includes IF_WORKFLOW = BI_OBJECT + BI_PERSISTENT

* i n s t a n c e   a t t r i b u t e s
  DATA:
*   o b j e c t   r e f e r e n c e s
    "! <p class="shorttext synchronized" lang="en">Document Viewer - ArchiveLink (copy of CL_DV_SDV_AO)</p>
    mo_viewer      TYPE REF TO zcl_ca_archive_cont_viewer READ-ONLY,
    "! <p class="shorttext synchronized" lang="en">Constants and value checks for archive content handler</p>
    mo_cvc_ac      TYPE REF TO zcl_ca_c_archive_content READ-ONLY,
    "! <p class="shorttext synchronized" lang="en">Constants and value checks for select options / range tables</p>
    mo_sel_options TYPE REF TO zcl_ca_c_sel_options READ-ONLY,

*   t a b l e s
    "! <p class="shorttext synchronized" lang="en">ArchiveLink and DMS document instances</p>
    mt_docs        TYPE zca_tt_archive_docs READ-ONLY,
    "! <p class="shorttext synchronized" lang="en">AL filter values passed for method GET</p>
    mt_filter_al   TYPE zca_tt_al_filter_ranges READ-ONLY,


*   s t r u c t u r e s
    "! <p class="shorttext synchronized" lang="en">Business Object key of archive object</p>
    ms_bo_key      TYPE sibflporb READ-ONLY,
    "! <p class="shorttext synchronized" lang="en">Business object short descriptions</p>
    ms_bo_desc     TYPE tojtt READ-ONLY,
    "! <p class="shorttext synchronized" lang="en">SAP ArchiveLink Customizing table</p>
    ms_toacu       TYPE toacu READ-ONLY,
    "! <p class="shorttext synchronized" lang="en">DMS filter values passed for method GET</p>
    ms_filter_dms  TYPE zca_s_dms_filter READ-ONLY,

*   s i n g l e   v a l u e s
    "! <p class="shorttext synchronized" lang="en">Number of selected documents</p>
    mv_count       TYPE syst_tabix READ-ONLY.

* i n s t a n c e   m e t h o d s
  METHODS:
    "! <p class="shorttext synchronized" lang="en">Archive a new object (currently for ArchiveLink only!)</p>
    "!
    "! @parameter iv_doc_type            | <p class="shorttext synchronized" lang="en">SAP ArchiveLink: Document type</p>
    "! @parameter iv_doc_class           | <p class="shorttext synchronized" lang="en">SAP ArchiveLink: Document class</p>
    "! @parameter iv_doc                 | <p class="shorttext synchronized" lang="en">Document (use FMs SCMS*XSTRING* for conversion)</p>
    "! @parameter it_doc_bin             | <p class="shorttext synchronized" lang="en">Table with raw data lines</p>
    "! @parameter it_doc_char            | <p class="shorttext synchronized" lang="en">Document content in character format</p>
    "! @parameter iv_doc_length          | <p class="shorttext synchronized" lang="en">Document length</p>
    "! @parameter iv_link_immed          | <p class="shorttext synchronized" lang="en">X = Link document immediately with object</p>
    "! @parameter iv_filename            | <p class="shorttext synchronized" lang="en">Original file name</p>
    "! @parameter iv_description         | <p class="shorttext synchronized" lang="en">Description (captured by user)</p>
    "! @parameter iv_creator             | <p class="shorttext synchronized" lang="en">User Id of Creator</p>
    "! @parameter result                 | <p class="shorttext synchronized" lang="en">CA-TBX: Extended archive connection incl. TOAV0</p>
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
    "!
    "! @parameter iv_refresh             | <p class="shorttext synchronized" lang="en">X=Refresh from DB, D=Add Delta (only new), ' '=Return buffer</p>
    "! @raising   zcx_ca_archive_content | <p class="shorttext synchronized" lang="en">CA-TBX exception: Error while handling Archive content</p>
    archive_via_dnd_dialog
      IMPORTING
        iv_refresh TYPE char1 DEFAULT zcl_ca_c_archive_content=>refresh_opt-add_delta_only
      RAISING
        zcx_ca_archive_content,

    "! <p class="shorttext synchronized" lang="en">Attach docs to business object (curr. for ArchiveLink only!)</p>
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

    "! <p class="shorttext synchronized" lang="en">For WF data binding: Attach archived docs. to a work item</p>
    "!
    "! <p>This method is intended to be used in the data binding to a workflow task to attach the filtered
    "! documents to the SAP standard container element _ADHOC_OBJECTS. Therefore the documents will be refreshed
    "! respecting the filter values.</p>
    "!
    "! <p>As the space for a data binding definition is very limited filters have to be prepared and then set
    "! via the methods {@link .METH:set_al_filter} and {@link .METH:set_dms_filter} of this interface. It is on
    "! purpose that they are split into two methods. So they can easier be used in container operations.</p>
    "!
    "! @parameter rt_adhoc_docs          | <p class="shorttext synchronized" lang="en">List with Adhoc documents</p>
    "! @raising   zcx_ca_archive_content | <p class="shorttext synchronized" lang="en">CA-TBX exception: Error while handling Archive content</p>
    attach_docs_2_wi
      RETURNING
        VALUE(rt_adhoc_docs) TYPE sibflporbt
      RAISING
        zcx_ca_archive_content,

    "! <p class="shorttext synchronized" lang="en">Close windows of viewer</p>
    "!
    "! @raising   zcx_ca_archive_content | <p class="shorttext synchronized" lang="en">CA-TBX exception: Error while handling ArchiveLink content</p>
    close_windows
      RAISING
        zcx_ca_archive_content,

    "! <p class="shorttext synchronized" lang="en">Copy content to other business object</p>
    "!
    "! @parameter is_bo_key_target    | <p class="shorttext synchronized" lang="en">Business object/class key - BOR Compatible</p>
    "! @parameter io_cont_target      | <p class="shorttext synchronized" lang="en">Target instance</p>
    "! @parameter it_docs             | <p class="shorttext synchronized" lang="en">Preselected conn. of source object - otherwise copy all</p>
    "! @parameter it_doc_type_mapping | <p class="shorttext synchronized" lang="en">Document type mappings for document copies</p>
    "! @parameter iv_refresh          | <p class="shorttext synchronized" lang="en">X = Refresh buffer and read from DB again</p>
    "! @raising   zcx_ca_param        | <p class="shorttext synchronized" lang="en">CA-TBX exception: Parameter error (INHERIT from this excep!)</p>
    "! @raising   zcx_ca_dbacc        | <p class="shorttext synchronized" lang="en">CA-TBX exception: Database access</p>
    copy_to_other_bo
      IMPORTING
        is_bo_key_target    TYPE sibflporb OPTIONAL
        io_cont_target      TYPE REF TO zcl_ca_archive_content OPTIONAL
        it_docs             TYPE zca_tt_toav0_ext OPTIONAL
        it_doc_type_mapping TYPE zca_tt_doc_type_mappings OPTIONAL
        iv_refresh          TYPE abap_bool DEFAULT zcl_ca_c_archive_content=>refresh_opt-refresh_from_db
      RAISING
        zcx_ca_param
        zcx_ca_dbacc,

    "! <p class="shorttext synchronized" lang="en">Delete connections (not the docs themselves!)</p>
    "!
    "! <p>Provide in parameter {@link .DATA:it_docs} the documents you want to delete. The filter parameters
    "! {@link .DATA:it_filter_al} and {@link .DATA:is_filter_dms} are for the refreshing of the documents after
    "! the deletion.</p>
    "!
    "! <p>Find details for parameter <strong>IS_FILTER_DMS</strong> here for method {@link .METH:get}.</p>
    "!
    "! @parameter it_docs                | <p class="shorttext synchronized" lang="en">Connections to be deleted</p>
    "! @parameter it_filter_al           | <p class="shorttext synchronized" lang="en">Filter for ArchiveLink result - selected in any case</p>
    "! @parameter is_filter_dms          | <p class="shorttext synchronized" lang="en">Filter for DMS (see method documentation)</p>
    "! @raising   zcx_ca_archive_content | <p class="shorttext synchronized" lang="en">CA-TBX exception: Error while handling Archive content</p>
    delete
      IMPORTING
        it_docs       TYPE zca_tt_toav0_ext OPTIONAL
        it_filter_al  TYPE zca_tt_al_filter_ranges OPTIONAL
        is_filter_dms TYPE zca_s_dms_filter OPTIONAL
      RAISING
        zcx_ca_archive_content,

    "! <p class="shorttext synchronized" lang="en">Display document(s)</p>
    "!
    "! <p>To reduce the toolbar of the viewer to specific buttons call method GET_VIEWER_DEFAULT_BUTTON of
    "! this class to get all buttons. Delete those you don't want to offer and pass the rest to parameter
    "! IT_BUTTONS of this method DISPLAY.</p>
    "!
    "! @parameter iv_use_singleton       | <p class="shorttext synchronized" lang="en">X = Use singleton (= SAP standard behavior)</p>
    "! @parameter iv_force_imc           | <p class="shorttext synchronized" lang="en">Open in external dynpro/mode / IO_PARENT is ignored</p>
    "! @parameter iv_force_no_imc        | <p class="shorttext synchronized" lang="en">Description</p>
    "! @parameter io_parent              | <p class="shorttext synchronized" lang="en">Parent container (for a single document only)</p>
    "! @parameter it_buttons             | <p class="shorttext synchronized" lang="en">Visible toolbar buttons (see comment to this method)</p>
    "! @parameter iv_no_toolbar          | <p class="shorttext synchronized" lang="en">X = Hide toolbar</p>
    "! @parameter iv_no_gos_toolbar      | <p class="shorttext synchronized" lang="en">X = Hide GOS toolbar</p>
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
    "! @parameter iv_refresh             | <p class="shorttext synchronized" lang="en">Refresh buffer (use const of MO_ARCH_FILTER-&gt;REFRESH_OPT-*)</p>
    "! @parameter iv_sort_by_time        | <p class="shorttext synchronized" lang="en">X = Order by creation time (can be much slower than normal!)</p>
    "! @parameter it_filter_al           | <p class="shorttext synchronized" lang="en">Filter ArchLink (use const ZCL_CA_C_ARCH...=&gt;AL_FILTER-*)</p>
    "!
    "! @parameter is_filter_dms          | <p class="shorttext synchronized" lang="en">Filter for DMS (see documentation of this method)</p>
    "! <p><strong>Hint to filter usage</strong>: Fill at least table T_SEL_DRAD of this parameter with the pairs
    "! of object type (DOKOB) and key (OBJKY) to get a result. Any initial or generic value is ignored,
    "! since these slow down the performance drastically. In table T_FILTER of this parameter the result can be
    "! more detailed. The fields DOKOB and OBJKY here will be ignored as they are defined in T_SEL_DRAD. Please
    "! use for the field name the prepared constants ZCL_CA_C_ARCHIVE_CONTENT=&gt;DMS_FILTER-*.</p>
    "!
    "! @parameter iv_only_act_vers       | <p class="shorttext synchronized" lang="en">X = Only active versions (only DMS relevant)</p>
    "! @parameter iv_only_rel_vers       | <p class="shorttext synchronized" lang="en">X = Only released versions (only DMS relevant)</p>
    "! @parameter result                 | <p class="shorttext synchronized" lang="en">Document instances sorted descending</p>
    "! @raising   zcx_ca_archive_content | <p class="shorttext synchronized" lang="en">CA-TBX exception: Error while handling Archive content</p>
    get
      IMPORTING
        iv_refresh       TYPE abap_bool DEFAULT zcl_ca_c_archive_content=>refresh_opt-no_refresh
        iv_sort_by_time  TYPE abap_bool DEFAULT abap_false
        it_filter_al     TYPE zca_tt_al_filter_ranges OPTIONAL
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

    "! <p class="shorttext synchronized" lang="en">Check whether the document is already buffered</p>
    "!
    "! @parameter iv_file_id | <p class="shorttext synchronized" lang="en">Physical document Id (= archive document Id)</p>
    "! @parameter result     | <p class="shorttext synchronized" lang="en">X = Document is in buffer</p>
    is_document_already_buffered
      IMPORTING
        iv_file_id    TYPE sdok_phid
      RETURNING
        VALUE(result) TYPE abap_bool,

    "! <p class="shorttext synchronized" lang="en">Set filter for ArchiveLink documents</p>
    "!
    "! <p>Use this method to set a filter primarily for method {@link attach_docs_2_wi} which is intended
    "! as a method for WF data binding. So it is possible to provide the user specific documents.</p>
    "!
    "! <p><strong>THIS OVERWRITES</strong> available filter settings provided via the methods {@link get} or
    "! {@link delete}!!</p>
    "!
    "! @parameter it_filter_al | <p class="shorttext synchronized" lang="en">Filter ArchLink (use const ZCL_CA_C_ARCH...=&gt;AL_FILTER-*)</p>
    set_al_filter
      IMPORTING
        it_filter_al TYPE zca_tt_al_filter_ranges,

    "! <p class="shorttext synchronized" lang="en">Set content, e. g. after manipulating the result in MT_DOCS</p>
    "!
    "! @parameter it_docs | <p class="shorttext synchronized" lang="en">ArchiveLink and DMS document instances</p>
    set_content
      IMPORTING
        it_docs TYPE zca_tt_archive_docs,

    "! <p class="shorttext synchronized" lang="en">Set filter for DMS documents</p>
    "!
    "! <p>Use this method to set a filter primarily for method {@link attach_docs_2_wi} which is intended
    "! as a method for WF data binding. So it is possible to provide the user specific documents.</p>
    "!
    "! <p><strong>THIS OVERWRITES</strong> available filter settings provided via the methods {@link get} or
    "! {@link delete}!!</p>
    "!
    "! @parameter is_filter_dms | <p class="shorttext synchronized" lang="en">Filter for DMS (see parameter documentation)</p>
    "!
    "! <p>Find details for parameter <strong>IS_FILTER_DMS</strong> here for method {@link .METH:get}.</p>
    set_dms_filter
      IMPORTING
        is_filter_dms TYPE zca_s_dms_filter.

ENDINTERFACE.
