"! <p class="shorttext synchronized" lang="en">CA-TBX: ArchiveLink + DMS: Archived document</p>
INTERFACE zif_ca_archive_doc PUBLIC.
*   c o n s t a n t s
  CONSTANTS:
    "! <p class="shorttext synchronized" lang="en">URL Addition to force the display by a specific application</p>
    BEGIN OF cs_url_addition,
      force_ascii TYPE string VALUE `&forceMimeType=application/x-ascii` ##NO_TEXT,
      force_pdf   TYPE string VALUE `&forceMimeType=application/pdf` ##NO_TEXT,
    END OF cs_url_addition.

* i n s t a n c e   a t t r i b u t e s
  DATA:
*   b u s i n e s s   o b j e c t s
    "! <p class="shorttext synchronized" lang="en">BO for document, either DRAW (=DMS) or IMAGE (=ArchiveLink)</p>
    mbo_document        TYPE sibflporb READ-ONLY ##NO_TEXT,

*   s t r u c t u r e s
    "! <p class="shorttext synchronized" lang="en">Document details (= connection entry)</p>
    ms_data             TYPE zca_s_toav0_ext READ-ONLY,
    "! <p class="shorttext synchronized" lang="en">Document class definition</p>
    ms_doc_class_def    TYPE toadd     READ-ONLY,
    "! <p class="shorttext synchronized" lang="en">Document class description</p>
    ms_doc_class_descr  TYPE toasd     READ-ONLY,
    "! <p class="shorttext synchronized" lang="en">Document type definition</p>
    ms_doc_type_def     TYPE toadv     READ-ONLY,
    "! <p class="shorttext synchronized" lang="en">Document type description</p>
    ms_doc_type_descr   TYPE toasp     READ-ONLY,

*   s i n g l e   v a l u e s
    "! <p class="shorttext synchronized" lang="en">Length of archived document (0 = not read from archive)</p>
    mv_doc_length       TYPE i         READ-ONLY,
    "! <p class="shorttext synchronized" lang="en">X = Document can be displayed implace</p>
    mv_implace_possible TYPE abap_bool READ-ONLY.

* i n s t a n c e   m e t h o d s
  METHODS:
    "! <p class="shorttext synchronized" lang="en">Delete a document (= connection)</p>
    "!
    "! @raising   zcx_ca_archive_content | <p class="shorttext synchronized" lang="en">Common exception: Error while handling ArchiveLink content</p>
    delete DEFAULT IGNORE
      RAISING
        zcx_ca_archive_content,

    "! <p class="shorttext synchronized" lang="en">Display single document</p>
    "!
    "! @parameter io_container           | <p class="shorttext synchronized" lang="en">Displaying container (e. g.custom or splitter container)</p>
    "! @parameter iv_url_add             | <p class="shorttext synchronized" lang="en">URL addition(s) - !!will be attached as passed!!</p>
    "! @parameter iv_force_implace       | <p class="shorttext synchronized" lang="en">X = Force displaying implace (use only with IO_PARENT)</p>
    "! @raising   zcx_ca_archive_content | <p class="shorttext synchronized" lang="en">Common exception: Error while handling ArchiveLink content</p>
    display DEFAULT IGNORE
      IMPORTING
        io_container     TYPE REF TO cl_gui_container OPTIONAL
        iv_url_add       TYPE string    OPTIONAL
        iv_force_implace TYPE abap_bool DEFAULT abap_false
      RAISING
        zcx_ca_archive_content,

    "! <p class="shorttext synchronized" lang="en">Release objects</p>
    free DEFAULT IGNORE,

    "! <p class="shorttext synchronized" lang="en">Get document as binary stream</p>
    "!
    "! @parameter result                 | <p class="shorttext synchronized" lang="en">Document as binary stream</p>
    "! @raising   zcx_ca_archive_content | <p class="shorttext synchronized" lang="en">Common exception: Error while handling ArchiveLink content</p>
    get_document DEFAULT IGNORE
      RETURNING
        VALUE(result) TYPE xstring
      RAISING
        zcx_ca_archive_content,

    "! <p class="shorttext synchronized" lang="en">Get URL to display object</p>
    "!
    "! @parameter iv_url_add             | <p class="shorttext synchronized" lang="en">URL addition(s) - !!will be attached as passed!!</p>
    "! @parameter result                 | <p class="shorttext synchronized" lang="en">URL for displaying document</p>
    "! @raising   zcx_ca_archive_content | <p class="shorttext synchronized" lang="en">Common exception: Error while handling ArchiveLink content</p>
    get_url DEFAULT IGNORE
      IMPORTING
        iv_url_add    TYPE string OPTIONAL
      RETURNING
        VALUE(result) TYPE saeuri
      RAISING
        zcx_ca_archive_content,

    "! <p class="shorttext synchronized" lang="en">Insert a new document (= connection)</p>
    "!
    "! <p>The other necessary parameters for the connection are already passed in GET_INSTANCE.</p>
    "!
    "! @parameter iv_filename            | <p class="shorttext synchronized" lang="en">Original file name</p>
    "! @parameter iv_description         | <p class="shorttext synchronized" lang="en">Description (captured by user)</p>
    "! @parameter iv_creator             | <p class="shorttext synchronized" lang="en">User Id of Creator</p>
    "! @raising   zcx_ca_archive_content | <p class="shorttext synchronized" lang="en">Common exception: Error while handling ArchiveLink content</p>
    insert DEFAULT IGNORE
      IMPORTING
        iv_filename    TYPE toaat-filename DEFAULT space
        iv_description TYPE toaat-descr    DEFAULT space
        iv_creator     TYPE toaat-creator  DEFAULT sy-uname
      RAISING
        zcx_ca_archive_content,

    "! <p class="shorttext synchronized" lang="en">Can document be displayed in a CFW container?</p>
    "!
    "! @parameter result | <p class="shorttext synchronized" lang="en">X = Display implace is possible</p>
    is_implace_possible DEFAULT IGNORE
      RETURNING
        VALUE(result) TYPE abap_bool.

ENDINTERFACE.
