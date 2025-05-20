prompt --application/set_environment
set define off verify off feedback off
whenever sqlerror exit sql.sqlcode rollback
--------------------------------------------------------------------------------
--
-- Oracle APEX export file
--
-- You should run this script using a SQL client connected to the database as
-- the owner (parsing schema) of the application or as a database user with the
-- APEX_ADMINISTRATOR_ROLE role.
--
-- This export file has been automatically generated. Modifying this file is not
-- supported by Oracle and can lead to unexpected application and/or instance
-- behavior now or in the future.
--
-- NOTE: Calls to apex_application_install override the defaults below.
--
--------------------------------------------------------------------------------
begin
wwv_flow_imp.import_begin (
 p_version_yyyy_mm_dd=>'2024.11.30'
,p_release=>'24.2.5'
,p_default_workspace_id=>57297072049795756375
,p_default_application_id=>181265
,p_default_id_offset=>0
,p_default_owner=>'WKSP_HACHEMI'
);
end;
/
 
prompt APPLICATION 181265 - carbonita 0.7
--
-- Application Export:
--   Application:     181265
--   Name:            carbonita 0.7
--   Date and Time:   18:37 Tuesday May 20, 2025
--   Exported By:     ZAKI
--   Flashback:       0
--   Export Type:     Component Export
--   Manifest
--     PLUGIN: 83922531498508275313
--   Manifest End
--   Version:         24.2.5
--   Instance ID:     63113759365424
--

begin
  -- replace components
  wwv_flow_imp.g_mode := 'REPLACE';
end;
/
prompt --application/shared_components/plugins/dynamic_action/com_zakpex_apex_carbonita_da
begin
wwv_flow_imp_shared.create_plugin(
 p_id=>wwv_flow_imp.id(83922531498508275313)
,p_plugin_type=>'DYNAMIC ACTION'
,p_name=>'COM.ZAKPEX.APEX.CARBONITA.DA'
,p_display_name=>'carbonita d'
,p_category=>'EXECUTE'
,p_plsql_code=>wwv_flow_string.join(wwv_flow_t_varchar2(
'/** 0.7.79',
'*/',
'    PROCEDURE raise_error_json (',
'        p_error_code in integer,',
'        p_error_message IN VARCHAR2 DEFAULT NULL',
'        ) IS',
'        BEGIN',
'            apex_json.initialize_output(p_http_header => TRUE);',
'            apex_json.flush;',
'            apex_json.open_object;',
'            apex_json.write(''status'', ''error'');',
'            apex_json.write(''errorcode'', p_error_code);',
'            apex_json.write(''message'', p_error_message);',
'            apex_json.close_object;',
'    END raise_error_json;',
'',
'    function extract_bind_vars(p_query in varchar2) return apex_t_varchar2 is',
'            v_bind_vars APEX_T_VARCHAR2;',
'        begin',
'            select distinct upper(substr(query_match,2))  -- Remove the leading colon',
'                    bulk collect   ',
'                        into v_bind_vars',
'                    from (',
'                        select ',
'                                regexp_substr(',
'                                    regexp_replace(',
'                                        regexp_replace(p_query,''--.*$'','''',1,0,''m''),  -- Remove single line comments',
'                                        ''/\*.*?\*/'','''',1,0                           -- Remove multi-line comments',
'                                        ),',
'                                        '':[[:alnum:]_]+'',     -- Match :name pattern',
'                                        1,level',
'                                ) as query_match',
'                             from dual',
'                            connect by regexp_substr(',
'                                    regexp_replace(',
'                                        regexp_replace(p_query,''--.*$'','''',1,0,''m''),  -- Remove single line comments',
'                                        ''/\*.*?\*/'','''',1,0                           -- Remove multi-line comments',
'                                        ),',
'                                        '':[[:alnum:]_]+'',     -- Match :name pattern',
'                                        1,level',
'                                ) is not null',
'                            )',
'                    where query_match is not null',
'            ;',
'            return v_bind_vars;',
'          EXCEPTION WHEN OTHERS THEN',
'            raise_error_json(''Bind variable extraction failed: '' || SQLERRM);',
'    end extract_bind_vars;',
'',
'    procedure bind_parameters(',
'            p_cursor    in integer, ',
'            p_variables in apex_t_varchar2,',
'            p_values    in apex_t_varchar2',
'            ) as',
'        begin',
'             -- Bind parameters',
'            FOR i IN 1..p_variables.COUNT LOOP -- NOTE : value is varchar2 !?',
'                DBMS_SQL.BIND_VARIABLE(p_cursor, ',
'                    '':'' || p_variables(i), ',
'                    p_values(i) ',
'                    );',
'            END LOOP;',
'    end bind_parameters;',
'',
'    procedure describe_columns(',
'                p_cursor in integer,',
'                l_column_count in out integer,',
'                l_desc_tab     in out DBMS_SQL.DESC_TAB3) as',
'        l_column_value  apex_exec.t_value; ',
'        begin',
'            ',
'            -- Describe columns',
'            DBMS_SQL.DESCRIBE_COLUMNS3(p_cursor, l_column_count, l_desc_tab);',
'',
'            -- Define columns',
'            FOR i IN 1..l_column_count LOOP',
'                CASE ',
'                    WHEN l_desc_tab(i).col_type = DBMS_TYPES.TYPECODE_CLOB ',
'                        THEN DBMS_SQL.DEFINE_COLUMN(p_cursor, i, l_column_value.clob_value);',
'',
'                    WHEN l_desc_tab(i).col_type in  (DBMS_TYPES.TYPECODE_VARCHAR2 , DBMS_TYPES.TYPECODE_VARCHAR, DBMS_TYPES.TYPECODE_CHAR )',
'                        THEN DBMS_SQL.DEFINE_COLUMN(p_cursor, i, l_column_value.varchar2_value, 32767);',
'',
'                    WHEN l_desc_tab(i).col_type in ( DBMS_TYPES.TYPECODE_NUMBER ) ',
'                        THEN DBMS_SQL.DEFINE_COLUMN(p_cursor, i, l_column_value.number_value);',
'',
'                    WHEN l_desc_tab(i).col_type = DBMS_TYPES.TYPECODE_DATE ',
'                        THEN DBMS_SQL.DEFINE_COLUMN(p_cursor, i, l_column_value.date_value);',
'',
'                    ELSE',
'                        DBMS_SQL.DEFINE_COLUMN(p_cursor, i, l_column_value.varchar2_value, 4000);',
'                    -- TODO : handle blob if necessary    ',
'                END CASE;',
'            END LOOP;',
'            ',
'    end describe_columns;',
'',
'    FUNCTION get_column_value(p_cursor in integer, p_col_num integer, p_col_type in BINARY_INTEGER) ',
'            RETURN clob IS',
'            l_return clob; --expect implicit conversion',
'            l_column_value  apex_exec.t_value;',
'        BEGIN',
'            ',
'            CASE p_col_type',
'                WHEN DBMS_TYPES.TYPECODE_DATE ',
'                        THEN  DBMS_SQL.COLUMN_VALUE(p_cursor, p_col_num, l_column_value.date_value); ',
'                              l_return := TO_CHAR(l_column_value.date_value, ''YYYY-MM-DD"T"HH24:MI:SS'');',
'                WHEN DBMS_TYPES.TYPECODE_NUMBER ',
'                        THEN  DBMS_SQL.COLUMN_VALUE(p_cursor, p_col_num, l_column_value.number_value); ',
'                              l_return := TO_CHAR(l_column_value.number_value) ;',
'                when DBMS_TYPES.TYPECODE_CLOB ',
'                        then DBMS_SQL.COLUMN_VALUE(p_cursor, p_col_num, l_column_value.clob_value); ',
'                             l_return := l_column_value.clob_value ;       ',
'                ELSE         DBMS_SQL.COLUMN_VALUE(p_cursor, p_col_num, l_column_value.varchar2_value); ',
'                             l_return := l_column_value.varchar2_value ;',
'            END case;',
'            return     l_return;',
'            exception when others then ',
'                raise_error_json(2011,''Error getting column value'');    ',
'    END get_column_value;',
'',
'    FUNCTION escape_json_value(p_value clob) RETURN clob IS',
'        BEGIN',
'            RETURN  REPLACE(p_value, ''"'', ''""'') ;',
'        exception when others then ',
'            raise_error_json(2012,''Error escaping'');    ',
'    END escape_json_value;',
'',
'    PROCEDURE add_json_value(p_part IN clob, p_clob IN OUT NOCOPY CLOB) IS',
'            l_clob clob;',
'        BEGIN',
'            IF p_part IS NULL THEN',
'                DBMS_LOB.WRITEAPPEND(p_clob, 4, ''null'');',
'            ELSif p_part is json then',
'                DBMS_LOB.APPEND(p_clob,p_part); ',
'            else',
'                l_clob := ''"'';',
'                dbms_lob.append(l_clob, escape_json_value(p_part));',
'                dbms_lob.writeappend(l_clob, length(''"''),''"'');',
'                dbms_lob.append(p_clob ,l_clob);',
'            END IF;',
'          exception when others then ',
'            raise_error_json(2013,''Error adding json''); ',
'    END add_json_value;',
'',
'    function generate_json_result(p_cursor in integer,p_column_count in integer,l_desc_tab in dbms_sql.DESC_TAB3) return clob as',
'            v_result clob;',
'',
'            l_cursor_status integer;',
'            l_row_count integer := 0;',
'',
'        begin',
'            DBMS_LOB.CREATETEMPORARY(v_result, TRUE);',
'            DBMS_LOB.WRITEAPPEND(v_result, 1, ''['');  --apex_json.open_array',
'',
'            -- Execute query',
'            l_cursor_status := DBMS_SQL.EXECUTE(p_cursor);',
'   ',
'            LOOP -- Process rows',
'                EXIT WHEN DBMS_SQL.FETCH_ROWS(p_cursor) = 0;  ',
'                IF l_row_count > 0 THEN',
'                    DBMS_LOB.WRITEAPPEND(v_result, 1, '','');',
'                END IF;',
'',
'                DBMS_LOB.WRITEAPPEND(v_result, 1, ''{'');',
'',
'                -- Build JSON object for current row',
'                FOR i IN 1..p_column_count LOOP                  ',
'                    IF i > 1 THEN DBMS_LOB.WRITEAPPEND(v_result, 1, '',''); END IF;',
'                    -- json attribute from column name',
'                    DBMS_LOB.WRITEAPPEND(v_result, LENGTH(''"'' || l_desc_tab(i).col_name || ''":''), ''"'' || l_desc_tab(i).col_name || ''":'');',
'                    -- json value  from column value',
'                    add_json_value(get_column_value(p_cursor, i, l_desc_tab(i).col_type   ),v_result);',
'                END LOOP;',
'                DBMS_LOB.WRITEAPPEND(v_result, 1, ''}'');',
'                l_row_count := l_row_count + 1;',
'            END LOOP;',
'',
'            DBMS_LOB.WRITEAPPEND(v_result, 1, '']''); --apex_json.close_array',
'            return v_result;',
'            exception when others then',
'                raise_error_json(2014,''Error generating json''); ',
'    end generate_json_result;',
'    ',
'    function query_to_clob( ',
'            p_query  IN varchar2 default null,',
'            p_static_id in varchar2 default null,',
'            p_values IN APEX_T_VARCHAR2 DEFAULT APEX_T_VARCHAR2()) return clob as',
'        l_region_id number;',
'        l_context            apex_exec.t_context;',
'        l_context_parameters apex_exec.t_parameters := apex_exec.c_empty_parameters;',
'        l_result_clob clob;',
'        begin',
'            -- check static_ID',
'            if p_static_id is not null then',
'                select region_id into l_region_id from apex_application_page_regions',
'                where application_id = V(''APP_ID'') and page_id = V(''APP_PAGE_ID'') and static_id = p_static_id',
'                ;',
'                l_context := apex_region.open_query_context (',
'                        p_page_id => V(''APP_PAGE_ID''),',
'                        p_region_id => l_region_id ); ',
'            else ',
'                l_context := apex_exec.open_query_context(',
'                    p_location        => apex_exec.c_location_local_db,',
'                    p_sql_query       => p_query,',
'                    p_sql_parameters  => l_context_parameters, --TODO : where l_context_parameters come from ?',
'                    p_auto_bind_items => true --TODO : should we l_autobind',
'                );',
'            end if;',
'        apex_json.initialize_clob_output(p_preserve => true);',
'        apex_json.open_object;',
'            apex_json.write_context(p_name    => ''rows'', p_context => l_context);',
'        apex_json.close_object;',
'        ',
'        l_result_clob := apex_json.get_clob_output;',
'        apex_json.free_output;',
'        ',
'        return l_result_clob;',
'        exception when others then',
'            apex_exec.close(l_context);',
'            apex_json.free_output;',
'            raise_error_json(2301,''error in query or static_id'');',
'                            ',
'    end query_to_clob;',
'        ',
'    FUNCTION query_to_json( --0.7.75',
'            p_query  IN varchar2,            ',
'            p_values IN APEX_T_VARCHAR2 DEFAULT APEX_T_VARCHAR2()',
'        ) RETURN CLOB IS',
'',
'        v_result CLOB;',
'        v_bind_vars APEX_T_VARCHAR2;',
'        v_cursor INTEGER := DBMS_SQL.OPEN_CURSOR;',
'        l_column_count  INTEGER;',
'        l_desc_tab DBMS_SQL.DESC_TAB3;',
'',
'        BEGIN',
'        v_bind_vars := extract_bind_vars(p_query);',
'        DBMS_SQL.PARSE(v_cursor, p_query, DBMS_SQL.NATIVE);',
'        bind_parameters(v_cursor, v_bind_vars, p_values);',
'        describe_columns(v_cursor,l_column_count,l_desc_tab);',
'        v_result := generate_json_result(v_cursor,l_column_count,l_desc_tab);',
'        DBMS_SQL.CLOSE_CURSOR(v_cursor);',
'',
'        RETURN v_result;',
'      EXCEPTION',
'        WHEN OTHERS THEN',
'            DBMS_SQL.CLOSE_CURSOR(v_cursor);',
'            raise_error_json(2014,''Error writing query to json''); ',
'            ',
'    END query_to_json;',
'',
'    PROCEDURE carbonita_get_template (',
'        p_template_static     IN VARCHAR2,',
'        p_app_id              IN NUMBER DEFAULT v(''APP_ID''),',
'        out_template_blob     OUT BLOB,',
'        out_template_mimetype OUT VARCHAR2',
'        ) AS',
'        BEGIN',
'            SELECT blob_content, mime_type',
'                INTO out_template_blob,out_template_mimetype',
'            FROM apex_application_files',
'            WHERE file_type = ''STATIC_FILE''',
'                AND flow_id = p_app_id',
'                AND filename = p_template_static;',
'',
'        EXCEPTION',
'            WHEN no_data_found THEN',
'                out_template_blob := NULL;',
'                out_template_mimetype := NULL;',
'    END carbonita_get_template;',
'',
'    function get_binding_values(',
'            p_binding_type in varchar2,',
'            p_binding_static in varchar2, ',
'            p_binding_pageitems in varchar2, ',
'            p_separator in varchar2 default '','') return apex_t_varchar2 as ',
'            l_binding_tmp   apex_t_varchar2:= apex_t_varchar2();',
'            l_binding_values apex_t_varchar2:= apex_t_varchar2();',
'        begin',
'            case p_binding_type',
'                when ''static'' then -- extract values  from p_binding_static',
'                    l_binding_values := apex_string.split(p_binding_static,p_separator);',
'',
'                when ''pageitems'' then                     ',
'                        -- extract values  from p_binding_pageitems',
'                        l_binding_tmp := apex_string.split(p_binding_pageitems,p_separator);',
'                        for i in 1..l_binding_tmp.count loop',
'                            l_binding_values.extend();',
'                            l_binding_values(i) := v(l_binding_tmp(i)); -- TODO find better way',
'                        end loop;',
'                else ',
'                        null; --l_autobind := true;                       ',
'                end case;',
'            return l_binding_values;    ',
'    end get_binding_values;',
'',
'',
'    FUNCTION  carbonita_get_data ( ',
'        p_query_type        in varchar2,   -- query ,json',
'        p_query             in varchar2, ',
'        p_query_static_id   in varchar2,',
'        p_binding_type      in varchar2 default ''static'', --static, pageitems, autobind ',
'        p_binding_static    in varchar2 default null,',
'        p_binding_pageitems in varchar2 default null,',
'',
'        p_separator         in varchar2 default '',''',
'        ) return clob as',
'',
'        l_result_clob           clob;',
'        l_binding_values    apex_t_varchar2 := apex_t_varchar2();',
'        l_autobind          boolean := true;',
'',
'        -- Variables for direct SQL handling',
'        l_cursor            integer;',
'',
'        begin',
'            if p_query_type in (''query'',''json'') then',
'            l_binding_values := get_binding_values(',
'                    p_binding_type      => p_binding_type,',
'                    p_binding_static    => p_binding_static,',
'                    p_binding_pageitems => p_binding_pageitems,',
'                    p_separator => p_separator',
'                    );',
'            end if ;        ',
'            case p_query_type ',
'                when ''query''  then l_result_clob := query_to_clob(p_query     => p_query          ,p_values => l_binding_values);   ',
'                when ''region'' then l_result_clob := query_to_clob(p_static_id => p_query_static_id,p_values=> l_binding_values);   ',
'                when ''json''   then l_result_clob := query_to_json(p_query,l_binding_values);                                      ',
'            end case;',
'',
'            -- APEX_DEBUG.INFO(l_result_clob);',
'            return l_result_clob;',
'            exception when others then',
'                dbms_sql.close_cursor(l_cursor);',
'                raise_error_json(2302,''"message":"''|| sqlerrm||''"}'');',
'    END carbonita_get_data;',
'',
'    PROCEDURE carbonita_get_report (',
'            p_url               IN VARCHAR2,-- nodejs server url',
'',
'            p_template_blob     IN BLOB,',
'            p_template_mimetype IN VARCHAR2 DEFAULT ''plain/txt'',',
'            p_report_data       IN CLOB, -- json data to send',
'',
'            p_output_format     IN VARCHAR2 DEFAULT ''pdf'', -- report type',
'            p_report_name       IN VARCHAR2 DEFAULT ''result'', -- report name',
'',
'           -- out_blob            OUT BLOB, -- obsolete TODO DELETEME',
'            out_clob64          OUT CLOB,',
'            out_mimetype        OUT VARCHAR2,',
'            out_filename        OUT VARCHAR2,',
'            out_size            OUT NUMBER',
'        )   AS',
'',
'        l_req_multipart   apex_web_service.t_multipart_parts;',
'        l_response_clob   CLOB;',
'        l_response_status NUMBER;',
'        l_response_mime   VARCHAR2(250);',
'        l_response_blob   BLOB;',
'        l_json            json_object_t;',
'        l_report_obj      json_object_t;',
'        l_template_clob64 CLOB ;',
'',
'        BEGIN',
'    ',
'        l_template_clob64 := apex_web_service.blob2clobbase64(p_template_blob);',
'        -- Clear any previous headers and set required ones',
'        apex_web_service.clear_request_headers;',
'        apex_web_service.set_request_headers(',
'            p_name_01  => ''User-Agent'',',
'            p_value_01 => ''APEX'', --used to debug nodejs ',
'            p_reset    => TRUE',
'        );',
'    ',
'        -- Build multipart form data -- TODO : ? change to json body ',
'        apex_web_service.append_to_multipart(p_multipart => l_req_multipart, p_name => ''templateEncoding'',  p_body => ''binary'');',
'        apex_web_service.append_to_multipart(p_multipart => l_req_multipart, p_name => ''templateContent'',   p_body_blob => p_template_blob);            ',
'        apex_web_service.append_to_multipart(p_multipart => l_req_multipart,p_name      => ''outputFormat'',p_body      => p_output_format);',
'        apex_web_service.append_to_multipart(p_multipart => l_req_multipart,p_name      => ''reportName'',p_body      => p_report_name);',
'        apex_web_service.append_to_multipart(p_multipart => l_req_multipart,p_name      => ''jsonData'',p_body      => p_report_data);',
'',
'',
'        -- Make POST request',
'        l_response_blob := apex_web_service.make_rest_request_b(',
'            p_url         => p_url,',
'            p_http_method => ''POST'',',
'            p_body_blob   => apex_web_service.generate_request_body(l_req_multipart)',
'        );',
'',
'        -- Capture response status and headers',
'        l_response_status := apex_web_service.g_status_code;',
'        FOR i in 1.. apex_web_service.g_headers.count LOOP',
'            if ( apex_web_service.g_headers(i).name = ''Content-Type'')  then',
'                l_response_mime := apex_web_service.g_headers(i).value;',
'            end if;',
'        END loop;',
'',
'        -- Validate response',
'        IF l_response_status != 200 THEN',
'        -- Try to get error message from response',
'            l_response_clob := apex_util.blob_to_clob(l_response_blob);',
'            raise_error_json(2201,''Server returned error ''',
'                          || l_response_status',
'                          || '': ''',
'                          || substr(l_response_clob, 1, 2000));',
'',
'            RETURN;',
'        END IF;',
'',
'        -- Convert response to CLOB',
'        l_response_clob := apex_util.blob_to_clob(l_response_blob);',
'',
'        if l_response_clob is json then ',
'            -- Parse JSON response',
'            <<parse_nodejs_response>>',
'            begin',
'                l_json := json_object_t.parse(l_response_clob);',
'                ',
'                EXCEPTION WHEN OTHERS THEN',
'                    raise_error_json(2202,''Invalid JSON response from server: ''',
'                                || sqlerrm',
'                                || '' - Raw response: ''',
'                                || substr(l_response_clob, 1, 2000));',
'                    RETURN;',
'            END parse_nodejs_response;',
'            ',
'            IF l_json.get_string(''status'') != ''success'' THEN',
'                raise_error_json(2203,''Server returned non-success status: '' || l_json.stringify);',
'                RETURN;',
'            END IF;',
'            ',
'            ',
'            l_report_obj := l_json.get_object(''reportgenerated'');',
'            out_mimetype := l_report_obj.get_string(''mimetype'');',
'            out_filename := l_report_obj.get_string(''filename'');',
'            ',
'            ',
'            out_clob64 := l_report_obj.get_clob(''base64''); ',
'            out_size   := dbms_lob.getlength(out_clob64);',
'            ',
'        else  null;',
'        end if;   ',
'        EXCEPTION',
'            WHEN OTHERS THEN',
'                raise_error_json(2204,''generate report: '' || sqlerrm);',
'',
'    END carbonita_get_report;',
'',
'',
'  FUNCTION carbonita_plugin_da_render (',
'        p_dynamic_action IN apex_plugin.t_dynamic_action,',
'        p_plugin         IN apex_plugin.t_plugin',
'    ) RETURN apex_plugin.t_dynamic_action_render_result AS',
'',
'        l_da_render_result        apex_plugin.t_dynamic_action_render_result;',
'        l_server_url              VARCHAR2(4000) := p_plugin.attribute_01;',
'        l_report_filename         VARCHAR2(4000) := p_dynamic_action.attribute_04;',
'        l_query                   VARCHAR2(4000) := p_dynamic_action.attribute_01;',
'        l_query_type              VARCHAR2(4000) := p_dynamic_action.attribute_10;',
'        l_query_static_id         VARCHAR2(4000) := p_dynamic_action.attribute_14;',
'        l_template_type           VARCHAR2(4000) := p_dynamic_action.attribute_15;',
'        l_template_pageitem       VARCHAR2(4000) := p_dynamic_action.attribute_05;',
'        l_output_format_attr_type VARCHAR2(4000) := p_dynamic_action.attribute_07;',
'        l_output_format_value     VARCHAR2(4000) := p_dynamic_action.attribute_03;',
'        l_output_format_item      VARCHAR2(4000) := p_dynamic_action.attribute_06;',
'        l_binding_attr_type       VARCHAR2(4000) := p_dynamic_action.attribute_11;',
'        l_binding_pageitems       VARCHAR2(4000) := p_dynamic_action.attribute_13;',
'        ',
'        l_pageitems_to_submit     VARCHAR2(4000);',
'    BEGIN',
'        apex_plugin_util.debug_dynamic_action(',
'            p_plugin         => p_plugin,',
'            p_dynamic_action => p_dynamic_action',
'        );',
'        apex_javascript.add_library(',
'            p_name                  => ''FileSaver'',',
'            p_directory             => p_plugin.file_prefix,',
'            p_check_to_add_minified => TRUE',
'        );',
'',
'        apex_javascript.add_library(',
'            p_name                  => ''carbonita'',',
'            p_directory             => p_plugin.file_prefix,',
'            p_check_to_add_minified => FALSE',
'        );',
'',
'        l_da_render_result.javascript_function := ''carbonita_js.carbonita_function'';',
'        l_da_render_result.ajax_identifier := apex_plugin.get_ajax_identifier; ',
'',
'        BEGIN-- prepare PageItems variables (Used for binding, format, template) to be submited in apex.server.plugin ... pageItems',
'            l_pageitems_to_submit := '''';',
'            IF l_binding_attr_type = ''pageitems'' THEN',
'                -- if no_data_found then it must be not PageItems',
'                SELECT',
'                    LISTAGG(''#'' || trim(column_value), '','') WITHIN GROUP(ORDER BY 1)',
'                    INTO l_pageitems_to_submit',
'                FROM TABLE ( apex_string.split(l_binding_pageitems, '','') );',
'            END IF;',
'',
'            IF l_template_type = ''PageItem'' THEN',
'                l_pageitems_to_submit := l_pageitems_to_submit|| '','' || ''#'' || l_template_pageitem;',
'            END IF;',
'',
'            IF l_query_type = ''autobind'' THEN ---- send item in query autobind',
'                        -- TODO optimize this slowbyslow ',
'                        -- TODO check for security issues',
'                FOR i IN 1..regexp_count(l_query, ''(:[[:alnum:]_]+)'') LOOP',
'                    l_pageitems_to_submit := l_pageitems_to_submit || '','' || ''#''',
'                                             || regexp_substr(l_query, ''(:([[:alnum:]_]+))'', 1, i, NULL,2);',
'                END LOOP;',
'            END IF;',
'',
'            IF l_output_format_attr_type = ''PageItem'' THEN',
'                l_pageitems_to_submit := l_pageitems_to_submit || '','' || ''#'' || l_output_format_item;',
'            END IF;',
'',
'            l_pageitems_to_submit := regexp_substr(l_pageitems_to_submit, ''[^,].*'');',
'        END; -- prepare PageItems variables',
'',
'        -- Parameters sent to carbonita_js',
'        l_da_render_result.attribute_01 := l_report_filename;',
'        l_da_render_result.attribute_02 := l_pageitems_to_submit; -- //"#P1_DEPTNO,#P1_EMPNO"',
'',
'        RETURN l_da_render_result;',
'  END carbonita_plugin_da_render;',
'',
'  FUNCTION carbonita_plugin_da_ajax (',
'        p_dynamic_action IN apex_plugin.t_dynamic_action,',
'        p_plugin         IN apex_plugin.t_plugin',
'    ) RETURN apex_plugin.t_dynamic_action_ajax_result AS',
'',
'        l_da_ajax_result              apex_plugin.t_dynamic_action_ajax_result;',
'        l_plg_server_url              VARCHAR2(250) := p_plugin.attribute_01;',
'        l_plg_separator               VARCHAR2(250) := p_plugin.attribute_02;',
'        l_report_name_attr            VARCHAR2(250) := p_dynamic_action.attribute_04; --apex_application.g_x01;',
'        l_debug_submited_items        VARCHAR2(4000) := apex_application.g_x02;',
'        l_query_da_attr               VARCHAR2(4000) := p_dynamic_action.attribute_01;',
'        l_query_da_attr_type          VARCHAR2(4000) := p_dynamic_action.attribute_08; --p_dynamic_action.attribute_10;',
'        l_query_da_attr_staticid      VARCHAR2(4000) := p_dynamic_action.attribute_14;   ',
'        l_query_data_clob             CLOB;',
'        l_template_da_attr_type       VARCHAR2(250) := p_dynamic_action.attribute_15;',
'        l_template_da_attr_static     VARCHAR2(250) := p_dynamic_action.attribute_02;',
'        l_template_da_attr_pageitem   VARCHAR2(250) := p_dynamic_action.attribute_05;',
'        l_template_out_blob           BLOB;           -- generated blob from template url',
'        l_template_out_mimetype       VARCHAR2(250);',
'        l_output_format_value         VARCHAR2(250);',
'        l_output_format_attr_type     VARCHAR2(4000) := p_dynamic_action.attribute_07;',
'        l_output_format_attr_static   VARCHAR2(4000) := p_dynamic_action.attribute_03;',
'        l_output_format_attr_pageitem VARCHAR2(4000) := p_dynamic_action.attribute_06;',
'        l_binding_attr_type           VARCHAR2(4000) := p_dynamic_action.attribute_11;',
'        l_binding_attr_static         VARCHAR2(4000) := p_dynamic_action.attribute_12;',
'        l_binding_attr_pageitems      VARCHAR2(4000) := p_dynamic_action.attribute_13;',
'        l_binding_values              apex_t_varchar2;',
'',
'        l_generated_filename          VARCHAR2(255);',
'        l_generated_mimetype          VARCHAR2(255);',
'        l_generated_blob              BLOB;',
'        l_generated_clob64            clob;',
'        l_generated_size              NUMBER;',
'    BEGIN',
'        apex_plugin_util.debug_dynamic_action (',
'                p_plugin         => p_plugin,',
'                p_dynamic_action => p_dynamic_action ',
'                    );',
'',
'        BEGIN -- retrieve template as blob',
'            carbonita_get_template(',
'                p_template_static     =>',
'                                   CASE l_template_da_attr_type',
'                                       WHEN ''Static''   THEN',
'                                           l_template_da_attr_static',
'                                       WHEN ''PageItem'' THEN',
'                                           v(l_template_da_attr_pageitem)',
'                                   END,',
'                p_app_id              => v(''APP_ID''),',
'                out_template_blob     => l_template_out_blob,',
'                out_template_mimetype => l_template_out_mimetype',
'            );',
'            EXCEPTION WHEN OTHERS THEN',
'                raise_error_json(2101,''Error  generate data clob'');',
'        END;',
'',
'        BEGIN -- prepare binding from plugin attribut (unless autobind there will be no need to )',
'',
'            -- TODO check if binding exists in the query     ',
'            l_binding_values := apex_t_varchar2();',
'',
'            -- set l_binding_values depending on l_binding_attr_type ',
'            CASE l_binding_attr_type',
'                WHEN ''static'' THEN -- get binding values from plugin attributes',
'                    FOR c IN (',
'                        SELECT',
'                            column_value binding_values',
'                        FROM',
'                            TABLE ( apex_string.split(l_binding_attr_static, l_plg_separator) )',
'                    ) LOOP',
'                        apex_string.push(l_binding_values, c.binding_values);',
'                    END LOOP;',
'                WHEN ''pageitems'' THEN -- get bindigs values from items listed in plugin attributese',
'                    FOR c IN (',
'                        SELECT',
'                            column_value page_items_values ',
'                                -- TODO check if better to use sys_context(''APEX$SESSION'',column_value) ',
'                        FROM',
'                            TABLE ( apex_string.split(l_binding_attr_pageitems, '','') )',
'                    ) LOOP',
'                        apex_string.push(l_binding_values,',
'                                         v(c.page_items_values));',
'                    END LOOP;',
'            END CASE;',
'',
'            EXCEPTION WHEN OTHERS THEN',
'                raise_error_json(2101,''Error binding'');',
'        END;',
'',
'        BEGIN -- retrieve data as json clob',
'            l_query_data_clob := carbonita_get_data(',
'                p_query             => l_query_da_attr,',
'                p_query_type        => l_query_da_attr_type,  -- query ,json, region',
'                p_query_static_id   => l_query_da_attr_staticid,  -- query ,json',
'                p_binding_type      => l_binding_attr_type, --static, pageitems, autobind ',
'                p_binding_static    => l_binding_attr_static,',
'                p_binding_pageitems => l_binding_attr_pageitems,',
'                p_separator         => l_plg_separator',
'            );',
'            EXCEPTION WHEN OTHERS THEN',
'                raise_error_json(2102,''Error  generate data clob'');',
'        END;',
'',
'        BEGIN -- send data and template to nodejs-carbonita ; retrieve generated report',
'            IF l_output_format_attr_type = ''PageItem'' THEN',
'                l_output_format_value := coalesce(',
'                                                v(l_output_format_attr_pageitem),',
'                                                ''pdf''',
'                                             );',
'            ELSE',
'                l_output_format_value := coalesce(l_output_format_attr_static, ''pdf'');',
'            END IF;',
'',
'            carbonita_get_report(',
'                p_url               => l_plg_server_url,',
'',
'                p_template_blob     => l_template_out_blob,',
'                p_template_mimetype => l_template_out_mimetype,',
'',
'                p_report_data       => l_query_data_clob,',
'',
'                p_output_format     => l_output_format_value,',
'                p_report_name       => l_report_name_attr,',
'',
'               -- out_blob            => l_generated_blob,',
'                out_clob64          => l_generated_clob64,',
'                out_mimetype        => l_generated_mimetype,',
'                out_filename        => l_generated_filename,',
'                out_size            => l_generated_size',
'            );',
'',
'            EXCEPTION WHEN OTHERS THEN',
'                ',
'                if dbms_lob.istemporary(l_query_data_clob) = 1 THEN',
'                    dbms_lob.freetemporary(l_query_data_clob);',
'                END IF;',
'                IF dbms_lob.istemporary(l_template_out_blob) = 1 THEN',
'                    dbms_lob.freetemporary(l_template_out_blob);',
'                end IF;',
'                raise_error_json(2103,''Error  generate report'');',
'                ',
'            --    raise;',
'        END;',
'',
'        BEGIN -- send back to js ajax call , used by filesaver in  js',
'            apex_json.initialize_output(p_http_header => TRUE);',
'            apex_json.flush;',
'            apex_json.open_object;',
'                apex_json.write(''status'', ''success'');',
'                apex_json.write(''download'', ''js'');',
'                apex_json.open_object(''reportgenerated'');',
'                    apex_json.write(''mimetype'', l_generated_mimetype);',
'                    apex_json.write(''filename'', l_generated_filename);',
'                    apex_json.write(''size'', dbms_lob.getlength(l_generated_clob64));',
'                    apex_json.write(''base64'',l_generated_clob64);                    ',
'                apex_json.close_object;',
'            apex_json.close_object;',
'        END;',
'',
'        RETURN l_da_ajax_result;',
'        EXCEPTION WHEN OTHERS THEN',
'            raise_error_json(2103,''Error  generate report'' || sqlerrm);',
'  END carbonita_plugin_da_ajax;'))
,p_api_version=>1
,p_render_function=>'carbonita_plugin_da_render'
,p_ajax_function=>'carbonita_plugin_da_ajax'
,p_substitute_attributes=>true
,p_version_scn=>15625868892078
,p_subscribe_plugin_settings=>true
,p_version_identifier=>'0.7.82'
,p_about_url=>'https://github.com/hachemizakaria/carbonita'
,p_files_version=>137
);
wwv_flow_imp_shared.create_plugin_attr_group(
 p_id=>wwv_flow_imp.id(83905018451887846095)
,p_plugin_id=>wwv_flow_imp.id(83922531498508275313)
,p_title=>'Binding'
,p_display_sequence=>10
);
wwv_flow_imp_shared.create_plugin_attr_group(
 p_id=>wwv_flow_imp.id(83905610129121498826)
,p_plugin_id=>wwv_flow_imp.id(83922531498508275313)
,p_title=>'Template'
,p_display_sequence=>20
);
wwv_flow_imp_shared.create_plugin_attr_group(
 p_id=>wwv_flow_imp.id(83905624080177642090)
,p_plugin_id=>wwv_flow_imp.id(83922531498508275313)
,p_title=>'Output'
,p_display_sequence=>30
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(83922531752081287570)
,p_plugin_id=>wwv_flow_imp.id(83922531498508275313)
,p_attribute_scope=>'APPLICATION'
,p_attribute_sequence=>1
,p_display_sequence=>10
,p_prompt=>'Carbonita Server URL'
,p_attribute_type=>'TEXT'
,p_is_required=>true
,p_is_translatable=>false
,p_examples=>'https://192.168.1.10'
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'# Server where request will be submited.',
'The Server should run nodejs , libreoffice and the required carbonita package'))
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(83922532575788290435)
,p_plugin_id=>wwv_flow_imp.id(83922531498508275313)
,p_attribute_scope=>'APPLICATION'
,p_attribute_sequence=>2
,p_display_sequence=>20
,p_prompt=>'Separator'
,p_attribute_type=>'TEXT'
,p_is_required=>true
,p_default_value=>','
,p_is_translatable=>false
,p_examples=>wwv_flow_string.join(wwv_flow_t_varchar2(
', ',
'10;20'))
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'When use multiple variables binding in the query, <br/>',
'we use a separator for values , Either for static value or Page Item <br/>'))
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(83922533013352294695)
,p_plugin_id=>wwv_flow_imp.id(83922531498508275313)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>1
,p_display_sequence=>10
,p_prompt=>'Dataset source query'
,p_attribute_type=>'SQL'
,p_is_required=>true
,p_default_value=>'select ENAME, JOB , SAL from emp'
,p_sql_min_column_count=>1
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_imp.id(44810161148610028430)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'IN_LIST'
,p_depending_on_expression=>'query,json'
,p_examples=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<h4> Query without binding </h4>',
'<pre><code>select ename,job, sal from emp</code></pre>',
'',
'<h4>Query using binding values stored in static or page item </h4>',
'<pre><code>',
'select ename,job, sal from emp',
'where deptno = :dept',
'</code></pre>',
'',
'<h4>Master/detail report with auto binding using substitutions variable from apex </h4>',
'<pre><code>',
'select ',
'   d.DEPTNO,',
'   d.DNAME,',
'   json_arrayagg(',
'      json_object(ENAME,JOB,SAL)',
'       returning clob) e',
'    from DEPT d left join emp e on ( e.deptno = d.deptno )',
'where d.deptno =  :P1_DEPT',
'group by d.deptno, d.dname',
'</code></pre>'))
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p>Query returning columns to be merged in the template</p>',
'<p>Note that type rows will generate column as uppercase so be aware that template can be case sensitive</p>'))
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(83922533484650296473)
,p_plugin_id=>wwv_flow_imp.id(83922531498508275313)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>2
,p_display_sequence=>151
,p_prompt=>'Template Static Filename'
,p_attribute_type=>'TEXT'
,p_is_required=>false
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_imp.id(83905610619909503994)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'Static'
,p_attribute_group_id=>wwv_flow_imp.id(83905610129121498826)
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(83922534027126299334)
,p_plugin_id=>wwv_flow_imp.id(83922531498508275313)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>3
,p_display_sequence=>60
,p_prompt=>'Output Format'
,p_attribute_type=>'SELECT LIST'
,p_is_required=>false
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_imp.id(83905809880851687628)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'Select'
,p_lov_type=>'STATIC'
,p_attribute_group_id=>wwv_flow_imp.id(83905624080177642090)
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(83922534575836300717)
,p_plugin_attribute_id=>wwv_flow_imp.id(83922534027126299334)
,p_display_sequence=>10
,p_display_value=>'docx'
,p_return_value=>'docx'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(83922534891162301457)
,p_plugin_attribute_id=>wwv_flow_imp.id(83922534027126299334)
,p_display_sequence=>20
,p_display_value=>'pdf'
,p_return_value=>'pdf'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(83922535378763302092)
,p_plugin_attribute_id=>wwv_flow_imp.id(83922534027126299334)
,p_display_sequence=>30
,p_display_value=>'txt'
,p_return_value=>'txt'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(83922535725330303431)
,p_plugin_attribute_id=>wwv_flow_imp.id(83922534027126299334)
,p_display_sequence=>40
,p_display_value=>'xlsx'
,p_return_value=>'xlsx'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(83922536100848304394)
,p_plugin_attribute_id=>wwv_flow_imp.id(83922534027126299334)
,p_display_sequence=>50
,p_display_value=>'pptx'
,p_return_value=>'pptx'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(83922536615448308647)
,p_plugin_id=>wwv_flow_imp.id(83922531498508275313)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>4
,p_display_sequence=>40
,p_prompt=>'Output filename'
,p_attribute_type=>'TEXT'
,p_is_required=>false
,p_default_value=>'reportname'
,p_is_translatable=>false
,p_attribute_group_id=>wwv_flow_imp.id(83905624080177642090)
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(83922537145948314244)
,p_plugin_id=>wwv_flow_imp.id(83922531498508275313)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>5
,p_display_sequence=>152
,p_prompt=>'Page Item'
,p_attribute_type=>'PAGE ITEM'
,p_is_required=>false
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_imp.id(83905610619909503994)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'PageItem'
,p_attribute_group_id=>wwv_flow_imp.id(83905610129121498826)
,p_help_text=>'Filename from PageItem'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(83922537632470316373)
,p_plugin_id=>wwv_flow_imp.id(83922531498508275313)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>6
,p_display_sequence=>70
,p_prompt=>'Output Format Page Item'
,p_attribute_type=>'PAGE ITEM'
,p_is_required=>false
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_imp.id(83905809880851687628)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'PageItem'
,p_attribute_group_id=>wwv_flow_imp.id(83905624080177642090)
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(83905809880851687628)
,p_plugin_id=>wwv_flow_imp.id(83922531498508275313)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>7
,p_display_sequence=>50
,p_prompt=>'Output Format Type'
,p_attribute_type=>'SELECT LIST'
,p_is_required=>false
,p_is_translatable=>false
,p_lov_type=>'STATIC'
,p_attribute_group_id=>wwv_flow_imp.id(83905624080177642090)
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(83905810791016692606)
,p_plugin_attribute_id=>wwv_flow_imp.id(83905809880851687628)
,p_display_sequence=>10
,p_display_value=>'Select'
,p_return_value=>'Select'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(83905811230220693440)
,p_plugin_attribute_id=>wwv_flow_imp.id(83905809880851687628)
,p_display_sequence=>20
,p_display_value=>'Page Item'
,p_return_value=>'PageItem'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(44810161148610028430)
,p_plugin_id=>wwv_flow_imp.id(83922531498508275313)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>8
,p_display_sequence=>80
,p_prompt=>'Dataset source type'
,p_attribute_type=>'SELECT LIST'
,p_is_required=>true
,p_default_value=>'query'
,p_is_translatable=>false
,p_lov_type=>'STATIC'
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'query for  select * from emp ',
'json for select json_object(*) from emp'))
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(44810162942778029110)
,p_plugin_attribute_id=>wwv_flow_imp.id(44810161148610028430)
,p_display_sequence=>10
,p_display_value=>'query'
,p_return_value=>'query'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(44810163254682030064)
,p_plugin_attribute_id=>wwv_flow_imp.id(44810161148610028430)
,p_display_sequence=>20
,p_display_value=>'json'
,p_return_value=>'json'
,p_help_text=>'select json_object(*) from emp'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(44812859812564743214)
,p_plugin_attribute_id=>wwv_flow_imp.id(44810161148610028430)
,p_display_sequence=>30
,p_display_value=>'region'
,p_return_value=>'region'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(44812628052066620403)
,p_plugin_id=>wwv_flow_imp.id(83922531498508275313)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>11
,p_display_sequence=>110
,p_prompt=>'Binding type'
,p_attribute_type=>'SELECT LIST'
,p_is_required=>false
,p_default_value=>'static'
,p_is_translatable=>false
,p_lov_type=>'STATIC'
,p_attribute_group_id=>wwv_flow_imp.id(83905018451887846095)
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'How to Bind variables used in the query',
'<h4>Static Value</h4>',
'<p>10,20</p>',
'<h4>Page Items</h4>',
'<p>P1_DEPT1,P1_DEPT2</p>',
'<h4>Auto Bind</h4>',
'<p>Auto bind using apex substitutions</p>'))
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(44812630632845621370)
,p_plugin_attribute_id=>wwv_flow_imp.id(44812628052066620403)
,p_display_sequence=>10
,p_display_value=>'static'
,p_return_value=>'static'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(44812631042200622319)
,p_plugin_attribute_id=>wwv_flow_imp.id(44812628052066620403)
,p_display_sequence=>20
,p_display_value=>'pageitems'
,p_return_value=>'pageitems'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(44812631422150623246)
,p_plugin_attribute_id=>wwv_flow_imp.id(44812628052066620403)
,p_display_sequence=>30
,p_display_value=>'autobind'
,p_return_value=>'autobind'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(83905019764831859064)
,p_plugin_id=>wwv_flow_imp.id(83922531498508275313)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>12
,p_display_sequence=>120
,p_prompt=>'Binding Static Value(s)'
,p_attribute_type=>'TEXT'
,p_is_required=>false
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_imp.id(44812628052066620403)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'static'
,p_attribute_group_id=>wwv_flow_imp.id(83905018451887846095)
,p_examples=>'10;20'
,p_help_text=>'Static values to replace binding variable'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(83905020775721865787)
,p_plugin_id=>wwv_flow_imp.id(83922531498508275313)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>13
,p_display_sequence=>130
,p_prompt=>'Binding Page Items'
,p_attribute_type=>'PAGE ITEMS'
,p_is_required=>false
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_imp.id(44812628052066620403)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'pageitems'
,p_attribute_group_id=>wwv_flow_imp.id(83905018451887846095)
,p_help_text=>'Page Items containing values to be used in bindings variables'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(44812847765354736084)
,p_plugin_id=>wwv_flow_imp.id(83922531498508275313)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>14
,p_display_sequence=>140
,p_prompt=>'Region StaticID'
,p_attribute_type=>'TEXT'
,p_is_required=>false
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_imp.id(44810161148610028430)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'region'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(83905610619909503994)
,p_plugin_id=>wwv_flow_imp.id(83922531498508275313)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>15
,p_display_sequence=>150
,p_prompt=>'Template Source'
,p_attribute_type=>'SELECT LIST'
,p_is_required=>false
,p_is_translatable=>false
,p_lov_type=>'STATIC'
,p_attribute_group_id=>wwv_flow_imp.id(83905610129121498826)
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(83905611400459505711)
,p_plugin_attribute_id=>wwv_flow_imp.id(83905610619909503994)
,p_display_sequence=>10
,p_display_value=>'Static'
,p_return_value=>'Static'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(83905611840628507069)
,p_plugin_attribute_id=>wwv_flow_imp.id(83905610619909503994)
,p_display_sequence=>20
,p_display_value=>'Page Item'
,p_return_value=>'PageItem'
);
wwv_flow_imp_shared.create_plugin_event(
 p_id=>wwv_flow_imp.id(83922544589734341605)
,p_plugin_id=>wwv_flow_imp.id(83922531498508275313)
,p_name=>'carbonita-data-generated'
,p_display_name=>'carbonita data generated'
);
wwv_flow_imp_shared.create_plugin_event(
 p_id=>wwv_flow_imp.id(83922544972618341606)
,p_plugin_id=>wwv_flow_imp.id(83922531498508275313)
,p_name=>'carbonita-data-sent'
,p_display_name=>'carbonita data sent to nodejs'
);
wwv_flow_imp_shared.create_plugin_event(
 p_id=>wwv_flow_imp.id(83922545316440341607)
,p_plugin_id=>wwv_flow_imp.id(83922531498508275313)
,p_name=>'carbonita-report-error-01'
,p_display_name=>'carbonita event 05'
);
wwv_flow_imp_shared.create_plugin_event(
 p_id=>wwv_flow_imp.id(83922545684792341608)
,p_plugin_id=>wwv_flow_imp.id(83922531498508275313)
,p_name=>'carbonita-report-received'
,p_display_name=>'carbonita Report Received from nodejs'
);
wwv_flow_imp_shared.create_plugin_event(
 p_id=>wwv_flow_imp.id(83922546100446341611)
,p_plugin_id=>wwv_flow_imp.id(83922531498508275313)
,p_name=>'carbonita-template-sent'
,p_display_name=>'carbonita Template sent to nodejs'
);
end;
/
begin
wwv_flow_imp.g_varchar2_table := wwv_flow_imp.empty_varchar2_table;
wwv_flow_imp.g_varchar2_table(1) := '636F6E73742056455253494F4E3D22302E372E3832223B76617220636172626F6E6974615F6A733D7B626173653634746F426C6F623A66756E6374696F6E28652C72297B69662822756E646566696E6564223D3D747970656F6620426C6F62297468726F';
wwv_flow_imp.g_varchar2_table(2) := '77206E6577204572726F722822426C6F627320617265206E6F7420737570706F7274656420696E20746869732062726F777365722E22293B636F6E7374206F3D61746F622865292C743D6F2E6C656E6774682C6E3D6E65772055696E7438417272617928';
wwv_flow_imp.g_varchar2_table(3) := '74293B666F72286C657420653D303B653C743B652B2B296E5B655D3D6F2E63686172436F646541742865293B72657475726E206E657720426C6F62285B6E2E6275666665725D2C7B747970653A727D297D2C636C6F623241727261793A66756E6374696F';
wwv_flow_imp.g_varchar2_table(4) := '6E28652C722C6F297B666F722876617220743D4D6174682E666C6F6F7228652E6C656E6774682F72292B312C6E3D303B6E3C743B6E2B2B296F2E7075736828652E736C69636528722A6E2C722A286E2B312929293B72657475726E206F7D2C636172626F';
wwv_flow_imp.g_varchar2_table(5) := '6E6974615F66756E6374696F6E3A66756E6374696F6E28297B636F6E736F6C652E6C6F67282276657273696F6E20302E372E383222292C636F6E736F6C652E6C6F672822737461727465642122293B636F6E737420653D746869733B696628652E697350';
wwv_flow_imp.g_varchar2_table(6) := '726F63657373696E672972657475726E3B652E697350726F63657373696E673D21303B636F6E737420723D617065782E7574696C2E73686F775370696E6E657228292C6F3D652E616374696F6E2E616A61784964656E7469666965722C743D652E616374';
wwv_flow_imp.g_varchar2_table(7) := '696F6E2E61747472696275746530317C7C227265706F7274222C6E3D652E616374696F6E2E61747472696275746530327C7C22223B617065782E64656275672E696E666F28225375626D69746564204974656D73203A20222C6E292C617065782E736572';
wwv_flow_imp.g_varchar2_table(8) := '7665722E706C7567696E286F2C7B7830313A742C706167654974656D733A6E7D2C7B737563636573733A66756E6374696F6E286F297B7472797B242822626F647922292E747269676765722822636172626F6E6974612D7265706F72742D726563656976';
wwv_flow_imp.g_varchar2_table(9) := '656422292C617065782E64656275672E696E666F282266756C6C2064617461222C6F293B636F6E737420653D6F2E7265706F727467656E6572617465643F2E6D696D65747970657C7C226170706C69636174696F6E2F6F637465742D73747265616D222C';
wwv_flow_imp.g_varchar2_table(10) := '723D6F2E7265706F727467656E6572617465643F2E6261736536343B69662872297B636F6E7374206E3D636172626F6E6974615F6A732E626173653634746F426C6F6228722C65293B226A73223D3D3D6F2E646F776E6C6F616426262266756E6374696F';
wwv_flow_imp.g_varchar2_table(11) := '6E223D3D747970656F66207361766541733F736176654173286E2C74293A28636F6E736F6C652E6572726F722822736176654173206973206E6F7420617661696C61626C65206F7220646F776E6C6F6164207761732063616E63656C65642E22292C616C';
wwv_flow_imp.g_varchar2_table(12) := '6572742822446F776E6C6F6164206661696C65643A205265717569726564206C696272617269657320617265206D697373696E672E2229297D7D63617463682865297B636F6E736F6C652E6572726F7228224572726F722070726F63657373696E672072';
wwv_flow_imp.g_varchar2_table(13) := '6573706F6E73653A222C65292C616C6572742822416E206572726F72206F63637572726564207768696C652067656E65726174696E6720746865207265706F72742E222C65297D66696E616C6C797B722E72656D6F766528292C652E697350726F636573';
wwv_flow_imp.g_varchar2_table(14) := '73696E673D21317D7D2C6572726F723A66756E6374696F6E286F2C74297B636F6E736F6C652E6572726F7228224150455820736572766572206572726F723A222C74292C242822626F647922292E747269676765722822636172626F6E6974612D726570';
wwv_flow_imp.g_varchar2_table(15) := '6F72742D6572726F722D303122292C616C6572742822536572766572206572726F723A20222B74292C722E72656D6F766528292C652E697350726F63657373696E673D21317D7D297D7D3B';
end;
/
begin
wwv_flow_imp_shared.create_plugin_file(
 p_id=>wwv_flow_imp.id(46348566942614708440)
,p_plugin_id=>wwv_flow_imp.id(83922531498508275313)
,p_file_name=>'carbonita.min.js'
,p_mime_type=>'text/javascript'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_imp.varchar2_to_blob(wwv_flow_imp.g_varchar2_table)
);
end;
/
begin
wwv_flow_imp.g_varchar2_table := wwv_flow_imp.empty_varchar2_table;
wwv_flow_imp.g_varchar2_table(1) := '2F2A2046696C6553617665722E6A730D0A202A20412073617665417328292046696C65536176657220696D706C656D656E746174696F6E2E0D0A202A20312E332E320D0A202A20323031362D30362D31362031383A32353A31390D0A202A0D0A202A2042';
wwv_flow_imp.g_varchar2_table(2) := '7920456C6920477265792C20687474703A2F2F656C69677265792E636F6D0D0A202A204C6963656E73653A204D49540D0A202A2020205365652068747470733A2F2F6769746875622E636F6D2F656C69677265792F46696C6553617665722E6A732F626C';
wwv_flow_imp.g_varchar2_table(3) := '6F622F6D61737465722F4C4943454E53452E6D640D0A202A2F0D0A0D0A2F2A676C6F62616C2073656C66202A2F0D0A2F2A6A736C696E7420626974776973653A20747275652C20696E64656E743A20342C206C6178627265616B3A20747275652C206C61';
wwv_flow_imp.g_varchar2_table(4) := '78636F6D6D613A20747275652C20736D617274746162733A20747275652C20706C7573706C75733A2074727565202A2F0D0A0D0A2F2A212040736F7572636520687474703A2F2F7075726C2E656C69677265792E636F6D2F6769746875622F46696C6553';
wwv_flow_imp.g_varchar2_table(5) := '617665722E6A732F626C6F622F6D61737465722F46696C6553617665722E6A73202A2F0D0A0D0A76617220736176654173203D20736176654173207C7C202866756E6374696F6E287669657729207B0D0A092275736520737472696374223B0D0A092F2F';
wwv_flow_imp.g_varchar2_table(6) := '204945203C3130206973206578706C696369746C7920756E737570706F727465640D0A0969662028747970656F662076696577203D3D3D2022756E646566696E656422207C7C20747970656F66206E6176696761746F7220213D3D2022756E646566696E';
wwv_flow_imp.g_varchar2_table(7) := '656422202626202F4D534945205B312D395D5C2E2F2E74657374286E6176696761746F722E757365724167656E742929207B0D0A090972657475726E3B0D0A097D0D0A097661720D0A09092020646F63203D20766965772E646F63756D656E740D0A0909';
wwv_flow_imp.g_varchar2_table(8) := '20202F2F206F6E6C79206765742055524C207768656E206E656365737361727920696E206361736520426C6F622E6A73206861736E2774206F76657272696464656E206974207965740D0A09092C206765745F55524C203D2066756E6374696F6E282920';
wwv_flow_imp.g_varchar2_table(9) := '7B0D0A09090972657475726E20766965772E55524C207C7C20766965772E7765626B697455524C207C7C20766965773B0D0A09097D0D0A09092C20736176655F6C696E6B203D20646F632E637265617465456C656D656E744E532822687474703A2F2F77';
wwv_flow_imp.g_varchar2_table(10) := '77772E77332E6F72672F313939392F7868746D6C222C20226122290D0A09092C2063616E5F7573655F736176655F6C696E6B203D2022646F776E6C6F61642220696E20736176655F6C696E6B0D0A09092C20636C69636B203D2066756E6374696F6E286E';
wwv_flow_imp.g_varchar2_table(11) := '6F646529207B0D0A090909766172206576656E74203D206E6577204D6F7573654576656E742822636C69636B22293B0D0A0909096E6F64652E64697370617463684576656E74286576656E74293B0D0A09097D0D0A09092C2069735F736166617269203D';
wwv_flow_imp.g_varchar2_table(12) := '202F636F6E7374727563746F722F692E7465737428766965772E48544D4C456C656D656E7429207C7C20766965772E7361666172690D0A09092C2069735F6368726F6D655F696F73203D2F4372694F535C2F5B5C645D2B2F2E74657374286E6176696761';
wwv_flow_imp.g_varchar2_table(13) := '746F722E757365724167656E74290D0A09092C207468726F775F6F757473696465203D2066756E6374696F6E28657829207B0D0A09090928766965772E736574496D6D656469617465207C7C20766965772E73657454696D656F7574292866756E637469';
wwv_flow_imp.g_varchar2_table(14) := '6F6E2829207B0D0A090909097468726F772065783B0D0A0909097D2C2030293B0D0A09097D0D0A09092C20666F7263655F7361766561626C655F74797065203D20226170706C69636174696F6E2F6F637465742D73747265616D220D0A09092F2F207468';
wwv_flow_imp.g_varchar2_table(15) := '6520426C6F62204150492069732066756E64616D656E74616C6C792062726F6B656E206173207468657265206973206E6F2022646F776E6C6F616466696E697368656422206576656E7420746F2073756273637269626520746F0D0A09092C2061726269';
wwv_flow_imp.g_varchar2_table(16) := '74726172795F7265766F6B655F74696D656F7574203D2031303030202A203430202F2F20696E206D730D0A09092C207265766F6B65203D2066756E6374696F6E2866696C6529207B0D0A090909766172207265766F6B6572203D2066756E6374696F6E28';
wwv_flow_imp.g_varchar2_table(17) := '29207B0D0A0909090969662028747970656F662066696C65203D3D3D2022737472696E672229207B202F2F2066696C6520697320616E206F626A6563742055524C0D0A09090909096765745F55524C28292E7265766F6B654F626A65637455524C286669';
wwv_flow_imp.g_varchar2_table(18) := '6C65293B0D0A090909097D20656C7365207B202F2F2066696C6520697320612046696C650D0A090909090966696C652E72656D6F766528293B0D0A090909097D0D0A0909097D3B0D0A09090973657454696D656F7574287265766F6B65722C2061726269';
wwv_flow_imp.g_varchar2_table(19) := '74726172795F7265766F6B655F74696D656F7574293B0D0A09097D0D0A09092C206469737061746368203D2066756E6374696F6E2866696C6573617665722C206576656E745F74797065732C206576656E7429207B0D0A0909096576656E745F74797065';
wwv_flow_imp.g_varchar2_table(20) := '73203D205B5D2E636F6E636174286576656E745F7479706573293B0D0A0909097661722069203D206576656E745F74797065732E6C656E6774683B0D0A0909097768696C652028692D2D29207B0D0A09090909766172206C697374656E6572203D206669';
wwv_flow_imp.g_varchar2_table(21) := '6C6573617665725B226F6E22202B206576656E745F74797065735B695D5D3B0D0A0909090969662028747970656F66206C697374656E6572203D3D3D202266756E6374696F6E2229207B0D0A0909090909747279207B0D0A0909090909096C697374656E';
wwv_flow_imp.g_varchar2_table(22) := '65722E63616C6C2866696C6573617665722C206576656E74207C7C2066696C657361766572293B0D0A09090909097D2063617463682028657829207B0D0A0909090909097468726F775F6F757473696465286578293B0D0A09090909097D0D0A09090909';
wwv_flow_imp.g_varchar2_table(23) := '7D0D0A0909097D0D0A09097D0D0A09092C206175746F5F626F6D203D2066756E6374696F6E28626C6F6229207B0D0A0909092F2F2070726570656E6420424F4D20666F72205554462D3820584D4C20616E6420746578742F2A2074797065732028696E63';
wwv_flow_imp.g_varchar2_table(24) := '6C7564696E672048544D4C290D0A0909092F2F206E6F74653A20796F75722062726F777365722077696C6C206175746F6D61746963616C6C7920636F6E76657274205554462D313620552B4645464620746F2045462042422042460D0A09090969662028';
wwv_flow_imp.g_varchar2_table(25) := '2F5E5C732A283F3A746578745C2F5C532A7C6170706C69636174696F6E5C2F786D6C7C5C532A5C2F5C532A5C2B786D6C295C732A3B2E2A636861727365745C732A3D5C732A7574662D382F692E7465737428626C6F622E747970652929207B0D0A090909';
wwv_flow_imp.g_varchar2_table(26) := '0972657475726E206E657720426C6F62285B537472696E672E66726F6D43686172436F646528307846454646292C20626C6F625D2C207B747970653A20626C6F622E747970657D293B0D0A0909097D0D0A09090972657475726E20626C6F623B0D0A0909';
wwv_flow_imp.g_varchar2_table(27) := '7D0D0A09092C2046696C655361766572203D2066756E6374696F6E28626C6F622C206E616D652C206E6F5F6175746F5F626F6D29207B0D0A09090969662028216E6F5F6175746F5F626F6D29207B0D0A09090909626C6F62203D206175746F5F626F6D28';
wwv_flow_imp.g_varchar2_table(28) := '626C6F62293B0D0A0909097D0D0A0909092F2F2046697273742074727920612E646F776E6C6F61642C207468656E207765622066696C6573797374656D2C207468656E206F626A6563742055524C730D0A0909097661720D0A09090909202066696C6573';
wwv_flow_imp.g_varchar2_table(29) := '61766572203D20746869730D0A090909092C2074797065203D20626C6F622E747970650D0A090909092C20666F726365203D2074797065203D3D3D20666F7263655F7361766561626C655F747970650D0A090909092C206F626A6563745F75726C0D0A09';
wwv_flow_imp.g_varchar2_table(30) := '0909092C2064697370617463685F616C6C203D2066756E6374696F6E2829207B0D0A090909090964697370617463682866696C6573617665722C2022777269746573746172742070726F6772657373207772697465207772697465656E64222E73706C69';
wwv_flow_imp.g_varchar2_table(31) := '742822202229293B0D0A090909097D0D0A090909092F2F206F6E20616E792066696C65737973206572726F72732072657665727420746F20736176696E672077697468206F626A6563742055524C730D0A090909092C2066735F6572726F72203D206675';
wwv_flow_imp.g_varchar2_table(32) := '6E6374696F6E2829207B0D0A0909090909696620282869735F6368726F6D655F696F73207C7C2028666F7263652026262069735F736166617269292920262620766965772E46696C6552656164657229207B0D0A0909090909092F2F2053616661726920';
wwv_flow_imp.g_varchar2_table(33) := '646F65736E277420616C6C6F7720646F776E6C6F6164696E67206F6620626C6F622075726C730D0A09090909090976617220726561646572203D206E65772046696C6552656164657228293B0D0A0909090909097265616465722E6F6E6C6F6164656E64';
wwv_flow_imp.g_varchar2_table(34) := '203D2066756E6374696F6E2829207B0D0A090909090909097661722075726C203D2069735F6368726F6D655F696F73203F207265616465722E726573756C74203A207265616465722E726573756C742E7265706C616365282F5E646174613A5B5E3B5D2A';
wwv_flow_imp.g_varchar2_table(35) := '3B2F2C2027646174613A6174746163686D656E742F66696C653B27293B0D0A0909090909090976617220706F707570203D20766965772E6F70656E2875726C2C20275F626C616E6B27293B0D0A0909090909090969662821706F7075702920766965772E';
wwv_flow_imp.g_varchar2_table(36) := '6C6F636174696F6E2E68726566203D2075726C3B0D0A0909090909090975726C3D756E646566696E65643B202F2F2072656C65617365207265666572656E6365206265666F7265206469737061746368696E670D0A0909090909090966696C6573617665';
wwv_flow_imp.g_varchar2_table(37) := '722E72656164795374617465203D2066696C6573617665722E444F4E453B0D0A0909090909090964697370617463685F616C6C28293B0D0A0909090909097D3B0D0A0909090909097265616465722E7265616441734461746155524C28626C6F62293B0D';
wwv_flow_imp.g_varchar2_table(38) := '0A09090909090966696C6573617665722E72656164795374617465203D2066696C6573617665722E494E49543B0D0A09090909090972657475726E3B0D0A09090909097D0D0A09090909092F2F20646F6E277420637265617465206D6F7265206F626A65';
wwv_flow_imp.g_varchar2_table(39) := '63742055524C73207468616E206E65656465640D0A090909090969662028216F626A6563745F75726C29207B0D0A0909090909096F626A6563745F75726C203D206765745F55524C28292E6372656174654F626A65637455524C28626C6F62293B0D0A09';
wwv_flow_imp.g_varchar2_table(40) := '090909097D0D0A090909090969662028666F72636529207B0D0A090909090909766965772E6C6F636174696F6E2E68726566203D206F626A6563745F75726C3B0D0A09090909097D20656C7365207B0D0A090909090909766172206F70656E6564203D20';
wwv_flow_imp.g_varchar2_table(41) := '766965772E6F70656E286F626A6563745F75726C2C20225F626C616E6B22293B0D0A09090909090969662028216F70656E656429207B0D0A090909090909092F2F204170706C6520646F6573206E6F7420616C6C6F772077696E646F772E6F70656E2C20';
wwv_flow_imp.g_varchar2_table(42) := '7365652068747470733A2F2F646576656C6F7065722E6170706C652E636F6D2F6C6962726172792F7361666172692F646F63756D656E746174696F6E2F546F6F6C732F436F6E6365707475616C2F536166617269457874656E73696F6E47756964652F57';
wwv_flow_imp.g_varchar2_table(43) := '6F726B696E677769746857696E646F7773616E64546162732F576F726B696E677769746857696E646F7773616E64546162732E68746D6C0D0A09090909090909766965772E6C6F636174696F6E2E68726566203D206F626A6563745F75726C3B0D0A0909';
wwv_flow_imp.g_varchar2_table(44) := '090909097D0D0A09090909097D0D0A090909090966696C6573617665722E72656164795374617465203D2066696C6573617665722E444F4E453B0D0A090909090964697370617463685F616C6C28293B0D0A09090909097265766F6B65286F626A656374';
wwv_flow_imp.g_varchar2_table(45) := '5F75726C293B0D0A090909097D0D0A0909093B0D0A09090966696C6573617665722E72656164795374617465203D2066696C6573617665722E494E49543B0D0A0D0A0909096966202863616E5F7573655F736176655F6C696E6B29207B0D0A090909096F';
wwv_flow_imp.g_varchar2_table(46) := '626A6563745F75726C203D206765745F55524C28292E6372656174654F626A65637455524C28626C6F62293B0D0A0909090973657454696D656F75742866756E6374696F6E2829207B0D0A0909090909736176655F6C696E6B2E68726566203D206F626A';
wwv_flow_imp.g_varchar2_table(47) := '6563745F75726C3B0D0A0909090909736176655F6C696E6B2E646F776E6C6F6164203D206E616D653B0D0A0909090909636C69636B28736176655F6C696E6B293B0D0A090909090964697370617463685F616C6C28293B0D0A09090909097265766F6B65';
wwv_flow_imp.g_varchar2_table(48) := '286F626A6563745F75726C293B0D0A090909090966696C6573617665722E72656164795374617465203D2066696C6573617665722E444F4E453B0D0A090909097D293B0D0A0909090972657475726E3B0D0A0909097D0D0A0D0A09090966735F6572726F';
wwv_flow_imp.g_varchar2_table(49) := '7228293B0D0A09097D0D0A09092C2046535F70726F746F203D2046696C6553617665722E70726F746F747970650D0A09092C20736176654173203D2066756E6374696F6E28626C6F622C206E616D652C206E6F5F6175746F5F626F6D29207B0D0A090909';
wwv_flow_imp.g_varchar2_table(50) := '72657475726E206E65772046696C65536176657228626C6F622C206E616D65207C7C20626C6F622E6E616D65207C7C2022646F776E6C6F6164222C206E6F5F6175746F5F626F6D293B0D0A09097D0D0A093B0D0A092F2F2049452031302B20286E617469';
wwv_flow_imp.g_varchar2_table(51) := '766520736176654173290D0A0969662028747970656F66206E6176696761746F7220213D3D2022756E646566696E656422202626206E6176696761746F722E6D73536176654F724F70656E426C6F6229207B0D0A090972657475726E2066756E6374696F';
wwv_flow_imp.g_varchar2_table(52) := '6E28626C6F622C206E616D652C206E6F5F6175746F5F626F6D29207B0D0A0909096E616D65203D206E616D65207C7C20626C6F622E6E616D65207C7C2022646F776E6C6F6164223B0D0A0D0A09090969662028216E6F5F6175746F5F626F6D29207B0D0A';
wwv_flow_imp.g_varchar2_table(53) := '09090909626C6F62203D206175746F5F626F6D28626C6F62293B0D0A0909097D0D0A09090972657475726E206E6176696761746F722E6D73536176654F724F70656E426C6F6228626C6F622C206E616D65293B0D0A09097D3B0D0A097D0D0A0D0A094653';
wwv_flow_imp.g_varchar2_table(54) := '5F70726F746F2E61626F7274203D2066756E6374696F6E28297B7D3B0D0A0946535F70726F746F2E72656164795374617465203D2046535F70726F746F2E494E4954203D20303B0D0A0946535F70726F746F2E57524954494E47203D20313B0D0A094653';
wwv_flow_imp.g_varchar2_table(55) := '5F70726F746F2E444F4E45203D20323B0D0A0D0A0946535F70726F746F2E6572726F72203D0D0A0946535F70726F746F2E6F6E77726974657374617274203D0D0A0946535F70726F746F2E6F6E70726F6772657373203D0D0A0946535F70726F746F2E6F';
wwv_flow_imp.g_varchar2_table(56) := '6E7772697465203D0D0A0946535F70726F746F2E6F6E61626F7274203D0D0A0946535F70726F746F2E6F6E6572726F72203D0D0A0946535F70726F746F2E6F6E7772697465656E64203D0D0A09096E756C6C3B0D0A0D0A0972657475726E207361766541';
wwv_flow_imp.g_varchar2_table(57) := '733B0D0A7D280D0A09202020747970656F662073656C6620213D3D2022756E646566696E6564222026262073656C660D0A097C7C20747970656F662077696E646F7720213D3D2022756E646566696E6564222026262077696E646F770D0A097C7C207468';
wwv_flow_imp.g_varchar2_table(58) := '69732E636F6E74656E740D0A29293B0D0A2F2F206073656C666020697320756E646566696E656420696E2046697265666F7820666F7220416E64726F696420636F6E74656E742073637269707420636F6E746578740D0A2F2F207768696C652060746869';
wwv_flow_imp.g_varchar2_table(59) := '7360206973206E7349436F6E74656E744672616D654D6573736167654D616E616765720D0A2F2F207769746820616E206174747269627574652060636F6E74656E7460207468617420636F72726573706F6E647320746F207468652077696E646F770D0A';
wwv_flow_imp.g_varchar2_table(60) := '0D0A69662028747970656F66206D6F64756C6520213D3D2022756E646566696E656422202626206D6F64756C652E6578706F72747329207B0D0A20206D6F64756C652E6578706F7274732E736176654173203D207361766541733B0D0A7D20656C736520';
wwv_flow_imp.g_varchar2_table(61) := '6966202828747970656F6620646566696E6520213D3D2022756E646566696E65642220262620646566696E6520213D3D206E756C6C292026262028646566696E652E616D6420213D3D206E756C6C2929207B0D0A2020646566696E65282246696C655361';
wwv_flow_imp.g_varchar2_table(62) := '7665722E6A73222C2066756E6374696F6E2829207B0D0A2020202072657475726E207361766541733B0D0A20207D293B0D0A7D0D0A';
end;
/
begin
wwv_flow_imp_shared.create_plugin_file(
 p_id=>wwv_flow_imp.id(83922539641322328414)
,p_plugin_id=>wwv_flow_imp.id(83922531498508275313)
,p_file_name=>'FileSaver.js'
,p_mime_type=>'text/javascript'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_imp.varchar2_to_blob(wwv_flow_imp.g_varchar2_table)
);
end;
/
begin
wwv_flow_imp.g_varchar2_table := wwv_flow_imp.empty_varchar2_table;
wwv_flow_imp.g_varchar2_table(1) := '2F2A212040736F7572636520687474703A2F2F7075726C2E656C69677265792E636F6D2F6769746875622F46696C6553617665722E6A732F626C6F622F6D61737465722F46696C6553617665722E6A73202A2F0A766172207361766541733D7361766541';
wwv_flow_imp.g_varchar2_table(2) := '737C7C66756E6374696F6E2865297B2275736520737472696374223B6966282128766F696420303D3D3D657C7C22756E646566696E656422213D747970656F66206E6176696761746F7226262F4D534945205B312D395D5C2E2F2E74657374286E617669';
wwv_flow_imp.g_varchar2_table(3) := '6761746F722E757365724167656E742929297B76617220743D652E646F63756D656E742C6E3D66756E6374696F6E28297B72657475726E20652E55524C7C7C652E7765626B697455524C7C7C657D2C6F3D742E637265617465456C656D656E744E532822';
wwv_flow_imp.g_varchar2_table(4) := '687474703A2F2F7777772E77332E6F72672F313939392F7868746D6C222C226122292C723D22646F776E6C6F616422696E206F2C613D2F636F6E7374727563746F722F692E7465737428652E48544D4C456C656D656E74297C7C652E7361666172692C69';
wwv_flow_imp.g_varchar2_table(5) := '3D2F4372694F535C2F5B5C645D2B2F2E74657374286E6176696761746F722E757365724167656E74292C643D66756E6374696F6E2874297B28652E736574496D6D6564696174657C7C652E73657454696D656F757429282866756E6374696F6E28297B74';
wwv_flow_imp.g_varchar2_table(6) := '68726F7720747D292C30297D2C733D66756E6374696F6E2865297B73657454696D656F7574282866756E6374696F6E28297B22737472696E67223D3D747970656F6620653F6E28292E7265766F6B654F626A65637455524C2865293A652E72656D6F7665';
wwv_flow_imp.g_varchar2_table(7) := '28297D292C346534297D2C663D66756E6374696F6E2865297B72657475726E2F5E5C732A283F3A746578745C2F5C532A7C6170706C69636174696F6E5C2F786D6C7C5C532A5C2F5C532A5C2B786D6C295C732A3B2E2A636861727365745C732A3D5C732A';
wwv_flow_imp.g_varchar2_table(8) := '7574662D382F692E7465737428652E74797065293F6E657720426C6F62285B537472696E672E66726F6D43686172436F6465283635323739292C655D2C7B747970653A652E747970657D293A657D2C753D66756E6374696F6E28742C752C63297B637C7C';
wwv_flow_imp.g_varchar2_table(9) := '28743D66287429293B766172206C2C703D746869732C763D226170706C69636174696F6E2F6F637465742D73747265616D223D3D3D742E747970652C773D66756E6374696F6E28297B2166756E6374696F6E28652C742C6E297B666F7228766172206F3D';
wwv_flow_imp.g_varchar2_table(10) := '28743D5B5D2E636F6E636174287429292E6C656E6774683B6F2D2D3B297B76617220723D655B226F6E222B745B6F5D5D3B6966282266756E6374696F6E223D3D747970656F662072297472797B722E63616C6C28652C6E7C7C65297D6361746368286529';
wwv_flow_imp.g_varchar2_table(11) := '7B642865297D7D7D28702C22777269746573746172742070726F6772657373207772697465207772697465656E64222E73706C69742822202229297D3B696628702E726561647953746174653D702E494E49542C722972657475726E206C3D6E28292E63';
wwv_flow_imp.g_varchar2_table(12) := '72656174654F626A65637455524C2874292C766F69642073657454696D656F7574282866756E6374696F6E28297B76617220652C743B6F2E687265663D6C2C6F2E646F776E6C6F61643D752C653D6F2C743D6E6577204D6F7573654576656E742822636C';
wwv_flow_imp.g_varchar2_table(13) := '69636B22292C652E64697370617463684576656E742874292C7728292C73286C292C702E726561647953746174653D702E444F4E457D29293B2166756E6374696F6E28297B69662828697C7C76262661292626652E46696C65526561646572297B766172';
wwv_flow_imp.g_varchar2_table(14) := '206F3D6E65772046696C655265616465723B72657475726E206F2E6F6E6C6F6164656E643D66756E6374696F6E28297B76617220743D693F6F2E726573756C743A6F2E726573756C742E7265706C616365282F5E646174613A5B5E3B5D2A3B2F2C226461';
wwv_flow_imp.g_varchar2_table(15) := '74613A6174746163686D656E742F66696C653B22293B652E6F70656E28742C225F626C616E6B22297C7C28652E6C6F636174696F6E2E687265663D74292C743D766F696420302C702E726561647953746174653D702E444F4E452C7728297D2C6F2E7265';
wwv_flow_imp.g_varchar2_table(16) := '616441734461746155524C2874292C766F696428702E726561647953746174653D702E494E4954297D286C7C7C286C3D6E28292E6372656174654F626A65637455524C287429292C76293F652E6C6F636174696F6E2E687265663D6C3A652E6F70656E28';
wwv_flow_imp.g_varchar2_table(17) := '6C2C225F626C616E6B22297C7C28652E6C6F636174696F6E2E687265663D6C293B702E726561647953746174653D702E444F4E452C7728292C73286C297D28297D2C633D752E70726F746F747970653B72657475726E22756E646566696E656422213D74';
wwv_flow_imp.g_varchar2_table(18) := '7970656F66206E6176696761746F7226266E6176696761746F722E6D73536176654F724F70656E426C6F623F66756E6374696F6E28652C742C6E297B72657475726E20743D747C7C652E6E616D657C7C22646F776E6C6F6164222C6E7C7C28653D662865';
wwv_flow_imp.g_varchar2_table(19) := '29292C6E6176696761746F722E6D73536176654F724F70656E426C6F6228652C74297D3A28632E61626F72743D66756E6374696F6E28297B7D2C632E726561647953746174653D632E494E49543D302C632E57524954494E473D312C632E444F4E453D32';
wwv_flow_imp.g_varchar2_table(20) := '2C632E6572726F723D632E6F6E777269746573746172743D632E6F6E70726F67726573733D632E6F6E77726974653D632E6F6E61626F72743D632E6F6E6572726F723D632E6F6E7772697465656E643D6E756C6C2C66756E6374696F6E28652C742C6E29';
wwv_flow_imp.g_varchar2_table(21) := '7B72657475726E206E6577207528652C747C7C652E6E616D657C7C22646F776E6C6F6164222C6E297D297D7D2822756E646566696E656422213D747970656F662073656C66262673656C667C7C22756E646566696E656422213D747970656F662077696E';
wwv_flow_imp.g_varchar2_table(22) := '646F77262677696E646F777C7C746869732E636F6E74656E74293B22756E646566696E656422213D747970656F66206D6F64756C6526266D6F64756C652E6578706F7274733F6D6F64756C652E6578706F7274732E7361766541733D7361766541733A22';
wwv_flow_imp.g_varchar2_table(23) := '756E646566696E656422213D747970656F6620646566696E6526266E756C6C213D3D646566696E6526266E756C6C213D3D646566696E652E616D642626646566696E65282246696C6553617665722E6A73222C2866756E6374696F6E28297B7265747572';
wwv_flow_imp.g_varchar2_table(24) := '6E207361766541737D29293B';
end;
/
begin
wwv_flow_imp_shared.create_plugin_file(
 p_id=>wwv_flow_imp.id(83922542368455329852)
,p_plugin_id=>wwv_flow_imp.id(83922531498508275313)
,p_file_name=>'FileSaver.min.js'
,p_mime_type=>'text/javascript'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_imp.varchar2_to_blob(wwv_flow_imp.g_varchar2_table)
);
end;
/
begin
wwv_flow_imp.g_varchar2_table := wwv_flow_imp.empty_varchar2_table;
wwv_flow_imp.g_varchar2_table(1) := '2F2A0D0A0D0A2A2F0D0A636F6E73742056455253494F4E203D2022302E372E3832223B0D0A0D0A76617220636172626F6E6974615F6A73203D207B0D0A20202020626173653634746F426C6F623A2066756E6374696F6E2028704261736536342C20704D';
wwv_flow_imp.g_varchar2_table(2) := '696D655479706529207B0D0A202020202020202069662028747970656F6620426C6F62203D3D3D2022756E646566696E65642229207B0D0A2020202020202020202020207468726F77206E6577204572726F722822426C6F627320617265206E6F742073';
wwv_flow_imp.g_varchar2_table(3) := '7570706F7274656420696E20746869732062726F777365722E22293B0D0A20202020202020207D0D0A0D0A2020202020202020636F6E73742062696E617279537472696E67203D2061746F622870426173653634293B0D0A2020202020202020636F6E73';
wwv_flow_imp.g_varchar2_table(4) := '74206C656E203D2062696E617279537472696E672E6C656E6774683B0D0A2020202020202020636F6E7374206279746573203D206E65772055696E74384172726179286C656E293B0D0A0D0A2020202020202020666F7220286C65742069203D20303B20';
wwv_flow_imp.g_varchar2_table(5) := '69203C206C656E3B20692B2B29207B0D0A20202020202020202020202062797465735B695D203D2062696E617279537472696E672E63686172436F646541742869293B0D0A20202020202020207D0D0A0D0A202020202020202072657475726E206E6577';
wwv_flow_imp.g_varchar2_table(6) := '20426C6F62285B62797465732E6275666665725D2C207B20747970653A20704D696D6554797065207D293B0D0A202020207D2C0D0A0D0A20202020636C6F623241727261793A2066756E6374696F6E2028636C6F622C2073697A652C2061727261792920';
wwv_flow_imp.g_varchar2_table(7) := '7B0D0A2020202020202020766172206C6F6F70436F756E74203D204D6174682E666C6F6F7228636C6F622E6C656E677468202F2073697A6529202B20313B0D0A2020202020202020666F7220287661722069203D20303B2069203C206C6F6F70436F756E';
wwv_flow_imp.g_varchar2_table(8) := '743B20692B2B29207B0D0A20202020202020202020202061727261792E7075736828636C6F622E736C6963652873697A65202A20692C2073697A65202A202869202B20312929293B0D0A20202020202020207D0D0A202020202020202072657475726E20';
wwv_flow_imp.g_varchar2_table(9) := '61727261793B0D0A202020207D2C0D0A0D0A20202020636172626F6E6974615F66756E6374696F6E3A2066756E6374696F6E202829207B0D0A0D0A2020202020202020636F6E736F6C652E6C6F67282776657273696F6E2027202B2056455253494F4E29';
wwv_flow_imp.g_varchar2_table(10) := '3B0D0A2020202020202020636F6E736F6C652E6C6F672827737461727465642127293B0D0A0D0A2020202020202020636F6E737420646154686973203D20746869733B0D0A2020202020202020696620286461546869732E697350726F63657373696E67';
wwv_flow_imp.g_varchar2_table(11) := '292072657475726E3B0D0A20202020202020206461546869732E697350726F63657373696E67203D20747275653B0D0A0D0A2020202020202020636F6E7374207370696E6E6572203D20617065782E7574696C2E73686F775370696E6E657228293B0D0A';
wwv_flow_imp.g_varchar2_table(12) := '0D0A2020202020202020636F6E73742061706578416A61784964656E746966696572203D206461546869732E616374696F6E2E616A61784964656E7469666965723B0D0A2020202020202020636F6E737420617065784F757470757446696C656E616D65';
wwv_flow_imp.g_varchar2_table(13) := '203D206461546869732E616374696F6E2E6174747269627574653031207C7C20227265706F7274223B0D0A2020202020202020636F6E737420617065784974656D73546F5375626D697420203D206461546869732E616374696F6E2E6174747269627574';
wwv_flow_imp.g_varchar2_table(14) := '653032207C7C2022223B0D0A2020202020202020617065782E64656275672E696E666F28275375626D69746564204974656D73203A20272C20617065784974656D73546F5375626D6974293B0D0A0D0A2020202020202020617065782E7365727665722E';
wwv_flow_imp.g_varchar2_table(15) := '706C7567696E280D0A20202020202020202020202061706578416A61784964656E7469666965722C207B0D0A2020202020202020202020207830313A20617065784F757470757446696C656E616D652C0D0A202020202020202020202020706167654974';
wwv_flow_imp.g_varchar2_table(16) := '656D733A20617065784974656D73546F5375626D69740D0A20202020202020207D2C0D0A2020202020202020202020207B0D0A202020202020202020202020202020202F2F726566726573684F626A6563743A20222350315F4D595F4C495354222C0D0A';
wwv_flow_imp.g_varchar2_table(17) := '202020202020202020202020202020202F2F6C6F6164696E67496E64696361746F723A20222350315F4D595F4C495354222C200D0A20202020202020202020202020202020737563636573733A2066756E6374696F6E20286461746146726F6D416A6178';
wwv_flow_imp.g_varchar2_table(18) := '29207B0D0A2020202020202020202020202020202020202020747279207B0D0A202020202020202020202020202020202020202020202020242827626F647927292E747269676765722827636172626F6E6974612D7265706F72742D7265636569766564';
wwv_flow_imp.g_varchar2_table(19) := '27293B0D0A202020202020202020202020202020202020202020202020617065782E64656275672E696E666F282766756C6C2064617461272C206461746146726F6D416A6178293B0D0A2020202020202020202020202020202020202020202020200D0A';
wwv_flow_imp.g_varchar2_table(20) := '202020202020202020202020202020202020202020202020636F6E7374207265706F72744D696D6574797065203D206461746146726F6D416A61782E7265706F727467656E6572617465643F2E6D696D6574797065207C7C20226170706C69636174696F';
wwv_flow_imp.g_varchar2_table(21) := '6E2F6F637465742D73747265616D223B0D0A202020202020202020202020202020202020202020202020636F6E7374207265706F7274426173653634203D206461746146726F6D416A61782E7265706F727467656E6572617465643F2E6261736536343B';
wwv_flow_imp.g_varchar2_table(22) := '0D0A2020202020202020202020202020202020202020202020202F2F636F6E737420785F7265706F72745F626C6F62203D204461746146726F6D416A61782E7265706F727467656E6572617465643F2E626C6F623B0D0A20202020202020202020202020';
wwv_flow_imp.g_varchar2_table(23) := '20202020202020202020200D0A202020202020202020202020202020202020202020202020696620287265706F727442617365363429207B0D0A20202020202020202020202020202020202020202020202020202020636F6E7374207265706F72744269';
wwv_flow_imp.g_varchar2_table(24) := '6E617279203D20636172626F6E6974615F6A732E626173653634746F426C6F62287265706F72744261736536342C207265706F72744D696D6574797065293B0D0A0D0A202020202020202020202020202020202020202020202020202020206966202864';
wwv_flow_imp.g_varchar2_table(25) := '61746146726F6D416A61782E646F776E6C6F6164203D3D3D20276A732720262620747970656F6620736176654173203D3D3D202766756E6374696F6E2729207B0D0A20202020202020202020202020202020202020202020202020202020202020207361';
wwv_flow_imp.g_varchar2_table(26) := '76654173287265706F727442696E6172792C20617065784F757470757446696C656E616D65293B0D0A202020202020202020202020202020202020202020202020202020207D20656C7365207B0D0A202020202020202020202020202020202020202020';
wwv_flow_imp.g_varchar2_table(27) := '2020202020202020202020636F6E736F6C652E6572726F722822736176654173206973206E6F7420617661696C61626C65206F7220646F776E6C6F6164207761732063616E63656C65642E22293B0D0A2020202020202020202020202020202020202020';
wwv_flow_imp.g_varchar2_table(28) := '202020202020202020202020616C6572742822446F776E6C6F6164206661696C65643A205265717569726564206C696272617269657320617265206D697373696E672E22293B0D0A20202020202020202020202020202020202020202020202020202020';
wwv_flow_imp.g_varchar2_table(29) := '7D0D0A2020202020202020202020202020202020202020202020207D0D0A0D0A20202020202020202020202020202020202020207D20636174636820286572726F7229207B0D0A202020202020202020202020202020202020202020202020636F6E736F';
wwv_flow_imp.g_varchar2_table(30) := '6C652E6572726F7228274572726F722070726F63657373696E6720726573706F6E73653A272C206572726F72293B0D0A202020202020202020202020202020202020202020202020616C6572742822416E206572726F72206F6363757272656420776869';
wwv_flow_imp.g_varchar2_table(31) := '6C652067656E65726174696E6720746865207265706F72742E222C206572726F72293B0D0A20202020202020202020202020202020202020207D2066696E616C6C79207B0D0A2020202020202020202020202020202020202020202020207370696E6E65';
wwv_flow_imp.g_varchar2_table(32) := '722E72656D6F766528293B0D0A2020202020202020202020202020202020202020202020206461546869732E697350726F63657373696E67203D2066616C73653B0D0A20202020202020202020202020202020202020207D0D0A20202020202020202020';
wwv_flow_imp.g_varchar2_table(33) := '2020202020207D2C0D0A202020202020202020202020202020206572726F723A2066756E6374696F6E20287868722C20704D65737361676529207B0D0A2020202020202020202020202020202020202020636F6E736F6C652E6572726F72282741504558';
wwv_flow_imp.g_varchar2_table(34) := '20736572766572206572726F723A272C20704D657373616765293B0D0A2020202020202020202020202020202020202020242827626F647927292E747269676765722827636172626F6E6974612D7265706F72742D6572726F722D303127293B0D0A2020';
wwv_flow_imp.g_varchar2_table(35) := '202020202020202020202020202020202020616C6572742822536572766572206572726F723A2022202B20704D657373616765293B0D0A20202020202020202020202020202020202020207370696E6E65722E72656D6F766528293B0D0A202020202020';
wwv_flow_imp.g_varchar2_table(36) := '20202020202020202020202020206461546869732E697350726F63657373696E67203D2066616C73653B0D0A202020202020202020202020202020207D0D0A2020202020202020202020207D293B0D0A202020207D0D0A7D3B';
end;
/
begin
wwv_flow_imp_shared.create_plugin_file(
 p_id=>wwv_flow_imp.id(83922542691223333711)
,p_plugin_id=>wwv_flow_imp.id(83922531498508275313)
,p_file_name=>'carbonita.js'
,p_mime_type=>'text/javascript'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_imp.varchar2_to_blob(wwv_flow_imp.g_varchar2_table)
);
end;
/
prompt --application/end_environment
begin
wwv_flow_imp.import_end(p_auto_install_sup_obj => nvl(wwv_flow_application_install.get_auto_install_sup_obj, false)
);
commit;
end;
/
set verify on feedback on define on
prompt  ...done
