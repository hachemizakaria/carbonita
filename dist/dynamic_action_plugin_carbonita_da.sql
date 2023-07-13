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
 p_version_yyyy_mm_dd=>'2023.04.28'
,p_release=>'23.1.1'
,p_default_workspace_id=>57297072049795756375
,p_default_application_id=>191112
,p_default_id_offset=>39051553675977681880
,p_default_owner=>'WKSP_HACHEMI'
);
end;
/
 
prompt APPLICATION 191112 - carbonita
--
-- Application Export:
--   Application:     191112
--   Name:            carbonita
--   Date and Time:   11:37 Thursday July 13, 2023
--   Exported By:     ZAKI
--   Flashback:       0
--   Export Type:     Component Export
--   Manifest
--     PLUGIN: 39112909937166464326
--   Manifest End
--   Version:         23.1.1
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
 p_id=>wwv_flow_imp.id(39112909937166464326)
,p_plugin_type=>'DYNAMIC ACTION'
,p_name=>'COM.ZAKPEX.APEX.CARBONITA.DA'
,p_display_name=>'carbonita da'
,p_category=>'EXECUTE'
,p_plsql_code=>wwv_flow_string.join(wwv_flow_t_varchar2(
'--create or replace PACKAGE BODY TEST_PLUGIN_CARBONITA AS',
'/*',
'carbonita da v0.6.18 ',
'',
'    Features :',
'        - choose format ',
'        - query type rows or json or autobind',
'        - parameters as static values',
'        - parameters as page items',
'        - use javascript to submit Page Items (otherwise we should submit page ?!)',
'        - master/details from nodejs side',
'',
'',
'    Known Issues :',
'        - if error in the query no way to know what was wrong ',
'        - using subtitutions in static values will not send values to server unless submitting page',
'        ',
'    TODO :',
'        - detect binding in the query excluding comments',
'*/',
' ',
'    ',
'    -- just a way to show errors',
'    PROCEDURE message_error (',
'        p_error_message IN VARCHAR2 DEFAULT NULL',
'    ) IS',
'    BEGIN',
'        apex_json.initialize_output(p_http_header => TRUE);',
'        apex_json.flush;',
'        apex_json.open_object;',
'        apex_json.write(''status'', ''error'');',
'        apex_json.write(''message'', p_error_message);',
'        apex_json.close_object;',
'    END message_error;',
'',
'    -- get template as blob from url or ... TODO',
'    PROCEDURE carbonita_pkg_get_report_template (',
'        p_template_static     IN VARCHAR2,',
'        p_app_id              IN NUMBER DEFAULT v(''APP_ID''),',
'        out_template_blob     OUT BLOB,',
'        out_template_mimetype OUT VARCHAR2',
'    ) AS',
'    BEGIN',
'        SELECT',
'            blob_content,',
'            mime_type',
'        INTO',
'            out_template_blob,',
'            out_template_mimetype',
'        FROM',
'            apex_application_files',
'        WHERE',
'                file_type = ''STATIC_FILE''',
'            AND flow_id = p_app_id',
'            AND filename = p_template_static;',
'',
'    EXCEPTION',
'        WHEN no_data_found THEN',
'            out_template_blob := NULL;',
'            out_template_mimetype := NULL;',
'    END carbonita_pkg_get_report_template;',
'',
'    -- call nodejs server to generate report from template and data ',
'    PROCEDURE carbonita_pkg_generate_report (',
'        p_template_blob     IN BLOB,',
'        p_template_mimetype IN VARCHAR2 DEFAULT ''plain/txt'',',
'        p_report_data       IN CLOB, -- json data to send',
'        p_report_name       IN VARCHAR2 DEFAULT ''result'', -- report name',
'        p_report_type       IN VARCHAR2 DEFAULT ''pdf'', -- report type',
'        p_url               IN VARCHAR2,--DEFAULT const_nodejs_url,-- nodejs server url where to  POST',
'',
'        out_blob            OUT BLOB,-- generated report as blob',
'        out_mimetype        OUT VARCHAR2,',
'        out_filename        OUT VARCHAR2,',
'        out_size            OUT NUMBER --??             ',
'    ) AS',
'        l_req_multipart      apex_web_service.t_multipart_parts;',
'        l_response_blob      BLOB;',
'        l_template_mime_type VARCHAR2(250);',
'        l_res_object         json_object_t;',
'    BEGIN',
'',
'        -- TEST just for test outside apex ',
'        -- TEST apex_util.set_security_group_id (p_security_group_id => 0); -- use schema security group',
'',
'        apex_web_service.g_request_headers.DELETE();',
'        apex_web_service.set_request_headers(',
'                    p_name_01 => ''Content-Type'', p_value_01 => ''application/json'', ',
'                    p_name_02 => ''User-Agent''  , p_value_02 => ''APEX'', ',
'                    p_reset => FALSE,',
'                    p_skip_if_exists => TRUE);',
'',
'        apex_web_service.append_to_multipart(p_multipart => l_req_multipart, p_name => ''report_type'', p_body => p_report_type);',
'',
'        apex_web_service.append_to_multipart(p_multipart => l_req_multipart, p_name => ''report_name'', p_body => p_report_name);',
'',
'        apex_web_service.append_to_multipart(p_multipart => l_req_multipart, p_name => ''req_encoding'', p_body => ''binary'');',
'',
'        apex_web_service.append_to_multipart(p_multipart => l_req_multipart, p_name => ''data_text'', ',
'                                           --  p_content_type  =>  ''application/json'',',
'                                             p_body => p_report_data);',
'',
'        apex_web_service.append_to_multipart(p_multipart => l_req_multipart, p_name => ''template_binary'', p_body_blob => p_template_blob',
'        );',
'',
'        l_response_blob := apex_web_service.make_rest_request_b(p_url => p_url, p_http_method => ''POST'', p_body_blob => apex_web_service.generate_request_body',
'        (l_req_multipart));',
'',
'        l_res_object := NEW json_object_t;',
'        FOR i IN 1..apex_web_service.g_headers.count LOOP',
'            l_res_object.put(apex_web_service.g_headers(i).name, apex_web_service.g_headers(i).value);',
'        END LOOP;',
'',
'        out_blob := l_response_blob;',
'        out_mimetype := l_res_object.get_string(''Content-Type'');',
'        out_filename := p_report_name;',
'        out_size := NULL;',
'    EXCEPTION',
'        WHEN OTHERS THEN',
'            message_error(''generate report'');',
'    END carbonita_pkg_generate_report;',
'   ',
'    -- generate clob data from query',
'    FUNCTION carbonita_pkg_get_data( -- with parameter',
'        p_query          IN VARCHAR2 ,',
'        p_binding_type   in varchar2 default null, --static , pageitems, autobind ',
'        p_binding_values IN apex_exec.t_parameters  default apex_exec.c_empty_parameters',
'    ) return clob as',
'        l_clob clob;',
'        ',
'        l_parameters     apex_exec.t_parameters;',
'        l_context apex_exec.t_context;',
'        l_autobind boolean;',
'                ',
'        ',
'    begin',
'        -- check query type ',
'            -- if json then use dbms_sql',
'            -- if rows convet to rows in order to use pex_json.write( l_refcursor)',
'        -- check binding ',
'        case  p_binding_type ',
'            when ''Static''     then  begin',
'                                        l_autobind   := false;',
'                                        l_parameters := p_binding_values;',
'                                    end;',
'            when ''PageItems''  then ',
'                                    begin',
'                                        l_autobind   := false;',
'                                        l_parameters := p_binding_values;   ',
'                                    end;    ',
'                                        ',
'            when ''autobind''   then  begin',
'                                        l_autobind   := true;',
'                                        l_parameters := apex_exec.c_empty_parameters;',
'                                    end;',
'            else null;                        ',
'        end case;',
'        ',
'        l_context := apex_exec.open_query_context( ',
'                                p_location   => apex_exec.c_location_local_db,',
'                                p_sql_query  => p_query ,',
'                                ',
'                                p_sql_parameters  => l_parameters ,',
'                                p_auto_bind_items => l_autobind',
'                                );',
'        ',
'        apex_json.initialize_clob_output(p_preserve => TRUE);',
'        apex_json.open_object;',
'            apex_json.write_context( p_name=>''rows'', p_context => l_context);--',
'        apex_json.close_object;',
'        ',
'        -- write result to the clob',
'        --dbms_lob.createtemporary(l_clob, true);',
'        l_clob := apex_json.get_clob_output; ',
'        --l_clob := replace(apex_json.get_clob_output,''\\\"'',''\"'');',
'        apex_json.free_output;',
'        ',
'        ',
'        ',
'        return l_clob;',
'        EXCEPTION',
'    WHEN others THEN',
'         --apex_debug.log_exception;',
'         apex_exec.close( l_context );',
'    RAISE;',
'    end carbonita_pkg_get_data ;',
'',
'    -- da plugin render',
'    FUNCTION carbonita_plugin_da_render (',
'        p_dynamic_action IN apex_plugin.t_dynamic_action,',
'        p_plugin         IN apex_plugin.t_plugin',
'    ) RETURN apex_plugin.t_dynamic_action_render_result AS',
'',
'        l_da_render_result    apex_plugin.t_dynamic_action_render_result;',
'        ',
'        l_server_url          VARCHAR2(4000) := p_plugin.attribute_01;',
'',
'        l_report_filename     VARCHAR2(4000) := p_dynamic_action.attribute_04;',
'        ',
'        l_query               VARCHAR2(4000) := p_dynamic_action.attribute_01;',
'        l_query_type          VARCHAR2(4000) := p_dynamic_action.attribute_10;',
'        ',
'        ',
'        ',
'        l_template_type       VARCHAR2(4000) := p_dynamic_action.attribute_15;',
'        -- not used l_template_static    VARCHAR2(4000) := p_dynamic_action.attribute_02; ',
'        l_template_PageItem    VARCHAR2(4000) := p_dynamic_action.attribute_05;',
'',
'        ',
'        l_output_format_attr_type  VARCHAR2(4000) := p_dynamic_action.attribute_07;',
'        l_output_format_value       VARCHAR2(4000) := p_dynamic_action.attribute_03;',
'        l_output_format_item  VARCHAR2(4000) := p_dynamic_action.attribute_06;',
'',
'        l_binding_attr_type        VARCHAR2(4000) := p_dynamic_action.attribute_11;',
'        -- not used in render l_binding_static      varchar2(4000) := p_dynamic_action.attribute_12; -- not used in render',
'        l_binding_PageItems   varchar2(4000) := p_dynamic_action.attribute_13;',
'        ',
'',
'        l_pageitems_to_submit VARCHAR2(4000);',
'',
'',
'    BEGIN',
'        apex_plugin_util.debug_dynamic_action(p_plugin => p_plugin, p_dynamic_action => p_dynamic_action);',
'        apex_javascript.add_library(p_name => ''FileSaver'', p_directory => p_plugin.file_prefix, p_check_to_add_minified => TRUE);',
'',
'        apex_javascript.add_library(p_name => ''carbonita'', p_directory => p_plugin.file_prefix, p_check_to_add_minified => FALSE);',
'',
'        l_da_render_result.javascript_function := ''carbonita_js.carbonita_function'';',
'        l_da_render_result.ajax_identifier := apex_plugin.get_ajax_identifier; ',
'',
'        -- prepare PageItems variables (Used for binding, format, template) to be submited in apex.server.plugin ... pageItems',
'        begin',
'            -- convert PageItems  value from  "P1_DEPTNO,P1_EMPNO" to "#P1_DEPTNO,#P1_EMPNO in order to send to js',
'            -- COMMENT : we just use items names , so do we need to check  ?',
'            ',
'        l_pageitems_to_submit := '''';        ',
'            ',
'        IF l_binding_attr_type = ''PageItems'' THEN',
'                -- if no_data_found then it must be not PageItems',
'                SELECT LISTAGG(''#'' || column_value, '','') WITHIN GROUP( ORDER BY 1 )',
'            INTO l_pageitems_to_submit',
'                FROM TABLE ( apex_string.split(l_binding_PageItems, '','') );',
'        END IF;',
'',
'        IF l_template_type = ''PageItem''   THEN',
'                l_pageitems_to_submit :=  l_pageitems_to_submit || '','' ',
'                        || '' #'' || l_template_PageItem;',
'        END IF; ',
'        ',
'        if l_output_format_attr_type = ''PageItem''   then',
'                l_pageitems_to_submit := l_pageitems_to_submit || '','' ',
'                        || ''#'' || l_output_format_item ;',
'        end if; ',
'        ',
'            l_pageitems_to_submit := REGEXP_SUBSTR(l_pageitems_to_submit, ''[^,].*'');',
'        ',
'',
'        end; -- prepare PageItems variables',
'        ',
'        -- Parameters sent to carbonita_js',
'        l_da_render_result.attribute_01 := l_report_filename;',
'        l_da_render_result.attribute_02 := l_pageitems_to_submit; -- //"#P1_DEPTNO,#P1_EMPNO"',
'',
'        RETURN l_da_render_result;',
'    END carbonita_plugin_da_render;',
'',
'    -- da plugin ajax : ',
'    FUNCTION carbonita_plugin_da_ajax (',
'        p_dynamic_action IN apex_plugin.t_dynamic_action,',
'        p_plugin         IN apex_plugin.t_plugin',
'    ) RETURN apex_plugin.t_dynamic_action_ajax_result AS',
'',
'        l_da_ajax_result            apex_plugin.t_dynamic_action_ajax_result;',
'        ',
'        l_plg_server_url                VARCHAR2(250) := p_plugin.attribute_01;',
'        l_plg_separator                 VARCHAR2(250) := p_plugin.attribute_02;',
'        ',
'        l_report_name_attr              VARCHAR2(250) := p_dynamic_action.attribute_04;',
'        l_debug_submited_items          VARCHAR2(4000) := apex_application.g_x02;',
'        ',
'',
'        l_query_da_attr                 VARCHAR2(4000) := p_dynamic_action.attribute_01;',
'        l_query_data_clob               CLOB;',
'        ',
'        ',
'        l_template_da_attr_Type         VARCHAR2(250)   := p_dynamic_action.attribute_15;',
'        l_template_da_attr_Static       VARCHAR2(250)   := p_dynamic_action.attribute_02;',
'        l_template_da_attr_PageItem     VARCHAR2(250)   := p_dynamic_action.attribute_05;',
'        ',
'        l_template_out_blob             BLOB;           -- generated blob from template url',
'        l_template_out_mimetype         VARCHAR2(250);',
'        ',
'        ',
'        l_output_format_value           VARCHAR2(250)  ;',
'        l_output_format_attr_type       VARCHAR2(4000) := p_dynamic_action.attribute_07;',
'        l_output_format_attr_Static     VARCHAR2(4000) := p_dynamic_action.attribute_03;',
'        l_output_format_attr_PageItem   VARCHAR2(4000) := p_dynamic_action.attribute_06;',
'        ',
'',
'        l_binding_attr_type             VARCHAR2(4000) := p_dynamic_action.attribute_11;',
'        l_binding_attr_Static           varchar2(4000) := p_dynamic_action.attribute_12;',
'        l_binding_attr_PageItems        varchar2(4000) := p_dynamic_action.attribute_13;',
'        ',
'        l_binding_values                apex_exec.t_parameters := apex_exec.c_empty_parameters;  ',
'        l_binding_names                 apex_t_varchar2;',
'        ',
'        l_generated_filename            VARCHAR2(255);',
'        l_generated_mimetype            VARCHAR2(255);',
'        l_generated_blob                BLOB;',
'        l_generated_size                NUMBER;',
'        ',
'    BEGIN',
'        ',
'        begin -- retrieve template as blob',
'        carbonita_pkg_get_report_template(',
'            p_template_static   => CASE l_template_da_attr_Type',
'                                        WHEN ''Static''   THEN l_template_da_attr_Static',
'                                        WHEN ''PageItem'' THEN v(l_template_da_attr_PageItem)',
'                                    END, ',
'            p_app_id            => v(''APP_ID''), ',
'            ',
'                out_template_blob       => l_template_out_blob, ',
'                out_template_mimetype   => l_template_out_mimetype',
'                );',
'        end;',
'',
'        ',
'        ',
'        BEGIN -- prepare binding from plugin attribut (unless autobind there will be no need to )',
'            ',
'            -- prepare binding names',
'            FOR i IN 1..regexp_count(l_query_da_attr, ''(:[[:alnum:]_]+)'') LOOP',
'                apex_string.push(l_binding_names, regexp_substr(l_query_da_attr, ''(:[[:alnum:]_]+)'', 1, i));',
'            END LOOP;',
'            ',
'            -- set l_binding_values depending on l_binding_attr_type ',
'            CASE l_binding_attr_type',
'                ',
'                WHEN ''Static'' THEN -- get binding values from plugin attributes',
'                    FOR c IN ( SELECT rownum i, column_value binding_values ',
'                              FROM TABLE ( apex_string.split(l_binding_attr_static, l_plg_separator))  ) LOOP',
'                        apex_exec.add_parameter( l_binding_values, l_binding_names(c.i),    c.binding_values );',
'                        END LOOP;',
'                            ',
'                WHEN ''PageItems'' THEN -- get bindigs values from items listed in plugin attributese',
'                    FOR c IN (  SELECT rownum i , column_value page_items_values ',
'                                -- TODO check if better to use sys_context(''APEX$SESSION'',column_value) ',
'                                 FROM   TABLE ( apex_string.split(l_binding_attr_PageItems, '','') ) ) LOOP',
'                        apex_exec.add_parameter( l_binding_values, l_binding_names(c.i),    v(c.page_items_values) );',
'                        END LOOP;',
'                else ',
'                    null;   -- autobind',
'                END CASE;',
'',
'        EXCEPTION',
'            WHEN OTHERS THEN  message_error(''Error binding'');',
'                 ',
'        END;',
'',
'         ',
'        BEGIN -- retrieve data as json clob',
'            l_query_data_clob :=  ',
'                carbonita_pkg_get_data(',
'                    p_query             => l_query_da_attr, ',
'                    p_binding_type      => l_binding_attr_type,',
'                    p_binding_values  => l_binding_values',
'                );',
'        EXCEPTION',
'            WHEN OTHERS THEN',
'                message_error(''Error  generate data clob'');',
'                ',
'        END;',
'',
'        ',
'        BEGIN -- send data and template to nodejs-carbonita ; retrieve generated report',
'        if l_output_format_attr_type = ''PageItem''    ',
'            then l_output_format_value := nvl(v(l_output_format_attr_PageItem) ,''pdf'') ;',
'            else l_output_format_value := nvl(l_output_format_attr_Static,''pdf'');',
'        end if; ',
'',
'            carbonita_pkg_generate_report(',
'                    p_url           => l_plg_server_url, ',
'                    p_report_name   => l_report_name_attr,',
'                    ',
'                    p_template_blob     => l_template_out_blob, ',
'                    p_template_mimetype => l_template_out_mimetype, ',
'                    ',
'                    p_report_data => l_query_data_clob, ',
'                    ',
'                    p_report_type => l_output_format_value, ',
'                    ',
'                        out_blob        => l_generated_blob, ',
'                        out_mimetype    => l_generated_mimetype, ',
'                        out_filename    => l_generated_filename, ',
'                        out_size    => l_generated_size);',
'',
'        EXCEPTION',
'            WHEN OTHERS THEN',
'                message_error(''Error  generate report'');',
'                dbms_lob.freetemporary( l_query_data_clob );',
'        END;',
'',
'        ',
'        BEGIN -- send back to js ajax call , used by filesaver in  js',
'            apex_json.initialize_output(p_http_header => TRUE);',
'            apex_json.flush;',
'            apex_json.open_object;',
'                apex_json.write(''status'', ''success'');',
'                apex_json.write(''download'', ''js'');',
'                 -- debug',
'                apex_json.open_object(''debug'');',
'                    apex_json.write(''format value''      ,l_output_format_value);',
'                    apex_json.write(''format type ''      ,l_output_format_attr_type);',
'                    apex_json.write(''submited items ''   ,l_debug_submited_items);',
'                    apex_json.write(''data'', l_query_data_clob);',
'                apex_json.close_object;',
'                apex_json.open_object(''reportgenerated'');',
'                    apex_json.write(''mimetype'', l_generated_mimetype);',
'                    apex_json.write(''filename'', l_generated_filename);',
'                    apex_json.write(''base64'', apex_web_service.blob2clobbase64(l_generated_blob));--  ''SGVsbG8gV29ybGQ=''); ',
'                apex_json.close_object;',
'            apex_json.close_object;',
'        END;',
'',
'        RETURN l_da_ajax_result;',
'    EXCEPTION',
'        WHEN OTHERS THEN',
'            raise_application_error(-20000, ''Error Occured: '' || sqlerrm);',
'            ',
'            ',
'    END carbonita_plugin_da_ajax;',
'    ',
''))
,p_default_escape_mode=>'HTML'
,p_api_version=>2
,p_render_function=>'carbonita_plugin_da_render'
,p_ajax_function=>'carbonita_plugin_da_ajax'
,p_substitute_attributes=>true
,p_subscribe_plugin_settings=>true
,p_version_identifier=>'0.6.18'
,p_about_url=>'https://github.com/hachemizakaria/carbonita'
,p_files_version=>99
);
wwv_flow_imp_shared.create_plugin_attr_group(
 p_id=>wwv_flow_imp.id(39095988567779687839)
,p_plugin_id=>wwv_flow_imp.id(39112909937166464326)
,p_title=>'Template'
,p_display_sequence=>20
);
wwv_flow_imp_shared.create_plugin_attr_group(
 p_id=>wwv_flow_imp.id(39096002518835831103)
,p_plugin_id=>wwv_flow_imp.id(39112909937166464326)
,p_title=>'Output'
,p_display_sequence=>30
);
wwv_flow_imp_shared.create_plugin_attr_group(
 p_id=>wwv_flow_imp.id(39095396890546035108)
,p_plugin_id=>wwv_flow_imp.id(39112909937166464326)
,p_title=>'Binding'
,p_display_sequence=>10
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(39112910190739476583)
,p_plugin_id=>wwv_flow_imp.id(39112909937166464326)
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
 p_id=>wwv_flow_imp.id(39112911014446479448)
,p_plugin_id=>wwv_flow_imp.id(39112909937166464326)
,p_attribute_scope=>'APPLICATION'
,p_attribute_sequence=>2
,p_display_sequence=>20
,p_prompt=>'Separator'
,p_attribute_type=>'TEXT'
,p_is_required=>true
,p_default_value=>';'
,p_is_translatable=>false
,p_examples=>wwv_flow_string.join(wwv_flow_t_varchar2(
'; ',
'10;20'))
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'When use multiple variables binding in the query, <br/>',
'we use a separator for values , Either for static value or Page Item <br/>'))
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(39112911452010483708)
,p_plugin_id=>wwv_flow_imp.id(39112909937166464326)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>1
,p_display_sequence=>10
,p_prompt=>'Sql Query'
,p_attribute_type=>'SQL'
,p_is_required=>true
,p_default_value=>'select ENAME, JOB , SAL from emp'
,p_sql_min_column_count=>1
,p_is_translatable=>false
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
 p_id=>wwv_flow_imp.id(39112911923308485486)
,p_plugin_id=>wwv_flow_imp.id(39112909937166464326)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>2
,p_display_sequence=>151
,p_prompt=>'Static Filename'
,p_attribute_type=>'TEXT'
,p_is_required=>false
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_imp.id(39095989058567693007)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'Static'
,p_attribute_group_id=>wwv_flow_imp.id(39095988567779687839)
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(39112912465784488347)
,p_plugin_id=>wwv_flow_imp.id(39112909937166464326)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>3
,p_display_sequence=>60
,p_prompt=>'Output Format'
,p_attribute_type=>'SELECT LIST'
,p_is_required=>false
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_imp.id(39096188319509876641)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'Select'
,p_lov_type=>'STATIC'
,p_attribute_group_id=>wwv_flow_imp.id(39096002518835831103)
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(39112913014494489730)
,p_plugin_attribute_id=>wwv_flow_imp.id(39112912465784488347)
,p_display_sequence=>10
,p_display_value=>'docx'
,p_return_value=>'docx'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(39112913329820490470)
,p_plugin_attribute_id=>wwv_flow_imp.id(39112912465784488347)
,p_display_sequence=>20
,p_display_value=>'pdf'
,p_return_value=>'pdf'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(39112913817421491105)
,p_plugin_attribute_id=>wwv_flow_imp.id(39112912465784488347)
,p_display_sequence=>30
,p_display_value=>'txt'
,p_return_value=>'txt'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(39112914163988492444)
,p_plugin_attribute_id=>wwv_flow_imp.id(39112912465784488347)
,p_display_sequence=>40
,p_display_value=>'xlsx'
,p_return_value=>'xlsx'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(39112914539506493407)
,p_plugin_attribute_id=>wwv_flow_imp.id(39112912465784488347)
,p_display_sequence=>50
,p_display_value=>'pptx'
,p_return_value=>'pptx'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(39112915054106497660)
,p_plugin_id=>wwv_flow_imp.id(39112909937166464326)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>4
,p_display_sequence=>40
,p_prompt=>'Output filename'
,p_attribute_type=>'TEXT'
,p_is_required=>false
,p_default_value=>'reportname'
,p_is_translatable=>false
,p_attribute_group_id=>wwv_flow_imp.id(39096002518835831103)
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(39112915584606503257)
,p_plugin_id=>wwv_flow_imp.id(39112909937166464326)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>5
,p_display_sequence=>152
,p_prompt=>'Page Item'
,p_attribute_type=>'PAGE ITEM'
,p_is_required=>false
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_imp.id(39095989058567693007)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'PageItem'
,p_attribute_group_id=>wwv_flow_imp.id(39095988567779687839)
,p_help_text=>'Filename from PageItem'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(39112916071128505386)
,p_plugin_id=>wwv_flow_imp.id(39112909937166464326)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>6
,p_display_sequence=>70
,p_prompt=>'Output Format Page Item'
,p_attribute_type=>'PAGE ITEM'
,p_is_required=>false
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_imp.id(39096188319509876641)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'PageItem'
,p_attribute_group_id=>wwv_flow_imp.id(39096002518835831103)
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(39096188319509876641)
,p_plugin_id=>wwv_flow_imp.id(39112909937166464326)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>7
,p_display_sequence=>50
,p_prompt=>'Output Format Type'
,p_attribute_type=>'SELECT LIST'
,p_is_required=>false
,p_is_translatable=>false
,p_lov_type=>'STATIC'
,p_attribute_group_id=>wwv_flow_imp.id(39096002518835831103)
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(39096189229674881619)
,p_plugin_attribute_id=>wwv_flow_imp.id(39096188319509876641)
,p_display_sequence=>10
,p_display_value=>'Select'
,p_return_value=>'Select'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(39096189668878882453)
,p_plugin_attribute_id=>wwv_flow_imp.id(39096188319509876641)
,p_display_sequence=>20
,p_display_value=>'Page Item'
,p_return_value=>'PageItem'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(39095394589992028306)
,p_plugin_id=>wwv_flow_imp.id(39112909937166464326)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>11
,p_display_sequence=>110
,p_prompt=>'Binding type'
,p_attribute_type=>'SELECT LIST'
,p_is_required=>false
,p_is_translatable=>false
,p_lov_type=>'STATIC'
,p_attribute_group_id=>wwv_flow_imp.id(39095396890546035108)
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'How to Bind variables used in the query',
'<h4>Static Value</h4>',
'<p>10;20</p>',
'<h4>Page Items</h4>',
'<p>P1_DEPT1,P1_DEPT2</p>',
'<h4>Auto Bind</h4>',
'<p>Auto bind using apex substitutions</p>'))
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(39095395404692030419)
,p_plugin_attribute_id=>wwv_flow_imp.id(39095394589992028306)
,p_display_sequence=>10
,p_display_value=>'Static'
,p_return_value=>'Static'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(39095395851501032612)
,p_plugin_attribute_id=>wwv_flow_imp.id(39095394589992028306)
,p_display_sequence=>20
,p_display_value=>'Page Items'
,p_return_value=>'PageItems'
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(39065922985502224878)
,p_plugin_attribute_id=>wwv_flow_imp.id(39095394589992028306)
,p_display_sequence=>30
,p_display_value=>'autobind'
,p_return_value=>'autobind'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(39095398203490048077)
,p_plugin_id=>wwv_flow_imp.id(39112909937166464326)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>12
,p_display_sequence=>120
,p_prompt=>'Static Value(s)'
,p_attribute_type=>'TEXT'
,p_is_required=>false
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_imp.id(39095394589992028306)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'Static'
,p_attribute_group_id=>wwv_flow_imp.id(39095396890546035108)
,p_examples=>'10;20'
,p_help_text=>'Static values to replace binding variable'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(39095399214380054800)
,p_plugin_id=>wwv_flow_imp.id(39112909937166464326)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>13
,p_display_sequence=>130
,p_prompt=>'Page Items'
,p_attribute_type=>'PAGE ITEMS'
,p_is_required=>false
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_imp.id(39095394589992028306)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'PageItems'
,p_attribute_group_id=>wwv_flow_imp.id(39095396890546035108)
,p_help_text=>'Page Items containing values to be used in bindings variables'
);
wwv_flow_imp_shared.create_plugin_attribute(
 p_id=>wwv_flow_imp.id(39095989058567693007)
,p_plugin_id=>wwv_flow_imp.id(39112909937166464326)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>15
,p_display_sequence=>150
,p_prompt=>'Template Source'
,p_attribute_type=>'SELECT LIST'
,p_is_required=>false
,p_is_translatable=>false
,p_lov_type=>'STATIC'
,p_attribute_group_id=>wwv_flow_imp.id(39095988567779687839)
);
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(39095989839117694724)
,p_plugin_attribute_id=>wwv_flow_imp.id(39095989058567693007)
,p_display_sequence=>10
,p_display_value=>'Static'
,p_return_value=>'Static'
);
end;
/
begin
wwv_flow_imp_shared.create_plugin_attr_value(
 p_id=>wwv_flow_imp.id(39095990279286696082)
,p_plugin_attribute_id=>wwv_flow_imp.id(39095989058567693007)
,p_display_sequence=>20
,p_display_value=>'Page Item'
,p_return_value=>'PageItem'
);
wwv_flow_imp_shared.create_plugin_event(
 p_id=>wwv_flow_imp.id(39112923028392530618)
,p_plugin_id=>wwv_flow_imp.id(39112909937166464326)
,p_name=>'carbonita-data-generated'
,p_display_name=>'carbonita data generated'
);
wwv_flow_imp_shared.create_plugin_event(
 p_id=>wwv_flow_imp.id(39112923411276530619)
,p_plugin_id=>wwv_flow_imp.id(39112909937166464326)
,p_name=>'carbonita-data-sent'
,p_display_name=>'carbonita data sent to nodejs'
);
wwv_flow_imp_shared.create_plugin_event(
 p_id=>wwv_flow_imp.id(39112923755098530620)
,p_plugin_id=>wwv_flow_imp.id(39112909937166464326)
,p_name=>'carbonita-report-error-01'
,p_display_name=>'carbonita event 05'
);
wwv_flow_imp_shared.create_plugin_event(
 p_id=>wwv_flow_imp.id(39112924123450530621)
,p_plugin_id=>wwv_flow_imp.id(39112909937166464326)
,p_name=>'carbonita-report-received'
,p_display_name=>'carbonita Report Received from nodejs'
);
wwv_flow_imp_shared.create_plugin_event(
 p_id=>wwv_flow_imp.id(39112924539104530624)
,p_plugin_id=>wwv_flow_imp.id(39112909937166464326)
,p_name=>'carbonita-template-sent'
,p_display_name=>'carbonita Template sent to nodejs'
);
end;
/
begin
wwv_flow_imp.g_varchar2_table := wwv_flow_imp.empty_varchar2_table;
wwv_flow_imp.g_varchar2_table(1) := '7661722076657273696F6E3D22302E362E3138222C636172626F6E6974615F6A733D7B626173653634746F426C6F623A66756E6374696F6E28722C65297B666F7228766172206F3D61746F622872292C743D6E6577204172726179286F2E6C656E677468';
wwv_flow_imp.g_varchar2_table(2) := '292C6E3D303B6E3C6F2E6C656E6774683B6E2B2B29745B6E5D3D6F2E63686172436F64654174286E293B76617220613D6E65772055696E743841727261792874293B7472797B72657475726E206E657720426C6F62285B615D2C7B747970653A657D297D';
wwv_flow_imp.g_varchar2_table(3) := '63617463682872297B696628766F69642030213D3D77696E646F772E426C6F624275696C646572297B76617220693D6E657720426C6F624275696C6465723B72657475726E20692E617070656E6428612E627566666572292C692E676574426C6F622865';
wwv_flow_imp.g_varchar2_table(4) := '297D7468726F77206E6577204572726F722822426C6F62206372656174696F6E206973206E6F7420737570706F727465642E22297D7D2C636C6F623241727261793A66756E6374696F6E28722C652C6F297B666F722876617220743D4D6174682E666C6F';
wwv_flow_imp.g_varchar2_table(5) := '6F7228722E6C656E6774682F65292B312C6E3D303B6E3C743B6E2B2B296F2E7075736828722E736C69636528652A6E2C652A286E2B312929293B72657475726E206F7D2C636172626F6E6974615F66756E6374696F6E3A66756E6374696F6E28297B636F';
wwv_flow_imp.g_varchar2_table(6) := '6E736F6C652E6C6F67282276657273696F6E20222B76657273696F6E292C636F6E736F6C652E6C6F67282273746172746564202122293B76617220723D617065782E7574696C2E73686F775370696E6E657228292C653D746869732C6F3D652E61637469';
wwv_flow_imp.g_varchar2_table(7) := '6F6E2E616A61784964656E7469666965722C743D652E616374696F6E2E61747472696275746530312C6E3D652E616374696F6E2E61747472696275746530323B617065782E7365727665722E706C7567696E286F2C7B7830313A742C706167654974656D';
wwv_flow_imp.g_varchar2_table(8) := '733A6E7D2C7B737563636573733A66756E6374696F6E2865297B636F6E736F6C652E6C6F672865292C242822626F647922292E747269676765722822636172626F6E6974612D7265706F72742D726563656976656422293B766172206F3D652E7265706F';
wwv_flow_imp.g_varchar2_table(9) := '727467656E6572617465642E6D696D65747970652C6E3D652E7265706F727467656E6572617465642E6261736536343B7472797B76617220613D636172626F6E6974615F6A732E626173653634746F426C6F62286E2C6F293B226A73223D3D3D652E646F';
wwv_flow_imp.g_varchar2_table(10) := '776E6C6F616426262873617665417328612C74292C722E72656D6F76652829297D63617463682865297B636F6E736F6C652E6C6F6728226572726F722066696C6522292C636F6E736F6C652E6C6F672865292C722E72656D6F766528297D7D2C6572726F';
wwv_flow_imp.g_varchar2_table(11) := '723A66756E6374696F6E28652C6F297B722E72656D6F766528292C242822626F647922292E747269676765722822636172626F6E6974612D7265706F72742D6572726F722D303122292C636F6E736F6C652E6C6F672822646F7468656A6F623A20617065';
wwv_flow_imp.g_varchar2_table(12) := '782E7365727665722E706C7567696E204552524F523A222C6F297D7D297D7D3B';
null;
end;
/
begin
wwv_flow_imp_shared.create_plugin_file(
 p_id=>wwv_flow_imp.id(39085701123326714440)
,p_plugin_id=>wwv_flow_imp.id(39112909937166464326)
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
null;
end;
/
begin
wwv_flow_imp_shared.create_plugin_file(
 p_id=>wwv_flow_imp.id(39112918079980517427)
,p_plugin_id=>wwv_flow_imp.id(39112909937166464326)
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
null;
end;
/
begin
wwv_flow_imp_shared.create_plugin_file(
 p_id=>wwv_flow_imp.id(39112920807113518865)
,p_plugin_id=>wwv_flow_imp.id(39112909937166464326)
,p_file_name=>'FileSaver.min.js'
,p_mime_type=>'text/javascript'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_imp.varchar2_to_blob(wwv_flow_imp.g_varchar2_table)
);
end;
/
begin
wwv_flow_imp.g_varchar2_table := wwv_flow_imp.empty_varchar2_table;
wwv_flow_imp.g_varchar2_table(1) := '2F2A0D0A0D0A2A2F0D0A0D0A7661722076657273696F6E203D2027302E362E3138273B0D0A0D0A76617220636172626F6E6974615F6A73203D207B0D0A20202020626173653634746F426C6F623A2066756E6374696F6E2028704261736536342C20704D';
wwv_flow_imp.g_varchar2_table(2) := '696D655479706529207B0D0A2020202020202020766172206279746543686172616374657273203D2061746F622870426173653634293B0D0A202020202020202076617220627974654E756D62657273203D206E65772041727261792862797465436861';
wwv_flow_imp.g_varchar2_table(3) := '726163746572732E6C656E677468293B0D0A2020202020202020666F7220287661722069203D20303B2069203C2062797465436861726163746572732E6C656E6774683B20692B2B29207B0D0A202020202020202020202020627974654E756D62657273';
wwv_flow_imp.g_varchar2_table(4) := '5B695D203D2062797465436861726163746572732E63686172436F646541742869293B0D0A20202020202020207D0D0A202020202020202076617220627974654172726179203D206E65772055696E7438417272617928627974654E756D62657273293B';
wwv_flow_imp.g_varchar2_table(5) := '0D0A2020202020202020747279207B0D0A20202020202020202020202072657475726E206E657720426C6F62285B6279746541727261795D2C207B20747970653A20704D696D6554797065207D293B0D0A20202020202020207D20636174636820286529';
wwv_flow_imp.g_varchar2_table(6) := '207B0D0A20202020202020202020202069662028747970656F662077696E646F772E426C6F624275696C64657220213D3D2022756E646566696E65642229207B0D0A20202020202020202020202020202020766172206262203D206E657720426C6F6242';
wwv_flow_imp.g_varchar2_table(7) := '75696C64657228293B0D0A2020202020202020202020202020202062622E617070656E64286279746541727261792E627566666572293B0D0A2020202020202020202020202020202072657475726E2062622E676574426C6F6228704D696D6554797065';
wwv_flow_imp.g_varchar2_table(8) := '293B0D0A2020202020202020202020207D20656C7365207B0D0A202020202020202020202020202020207468726F77206E6577204572726F722822426C6F62206372656174696F6E206973206E6F7420737570706F727465642E22293B0D0A2020202020';
wwv_flow_imp.g_varchar2_table(9) := '202020202020207D0D0A20202020202020207D0D0A202020207D2C0D0A0D0A20202020636C6F623241727261793A2066756E6374696F6E2028636C6F622C2073697A652C20617272617929207B0D0A2020202020202020766172206C6F6F70436F756E74';
wwv_flow_imp.g_varchar2_table(10) := '203D204D6174682E666C6F6F7228636C6F622E6C656E677468202F2073697A6529202B20313B0D0A2020202020202020666F7220287661722069203D20303B2069203C206C6F6F70436F756E743B20692B2B29207B0D0A20202020202020202020202061';
wwv_flow_imp.g_varchar2_table(11) := '727261792E7075736828636C6F622E736C6963652873697A65202A20692C2073697A65202A202869202B20312929293B0D0A20202020202020207D0D0A202020202020202072657475726E2061727261793B0D0A202020207D2C0D0A0D0A202020206361';
wwv_flow_imp.g_varchar2_table(12) := '72626F6E6974615F66756E6374696F6E3A2066756E6374696F6E202829207B202F2F6461436F6E746578742C206F7074696F6E730D0A0D0A2020202020202020636F6E736F6C652E6C6F67282776657273696F6E2027202B2076657273696F6E293B0D0A';
wwv_flow_imp.g_varchar2_table(13) := '2020202020202020636F6E736F6C652E6C6F67282773746172746564202127293B0D0A2020202020202020766172207370696E6E6572203D20617065782E7574696C2E73686F775370696E6E657228293B0D0A0D0A0D0A20202020202020207661722064';
wwv_flow_imp.g_varchar2_table(14) := '6154686973203D20746869733B0D0A20202020202020202F2F3F2074726967676572203D202223222B746869732E74726967676572696E67456C656D656E742E69643B0D0A0D0A0D0A202020202020202076617220765F416A61784964656E7469666965';
wwv_flow_imp.g_varchar2_table(15) := '72203D206461546869732E616374696F6E2E616A61784964656E7469666965723B0D0A0D0A20202020202020202F2F207661726961626C65732072656369657665642066726F6D2072656E6465720D0A0D0A202020202020202076617220765F6F757470';
wwv_flow_imp.g_varchar2_table(16) := '75745F66696C656E616D65203D206461546869732E616374696F6E2E61747472696275746530313B0D0A0D0A20202020202020200D0A202020202020202076617220765F6974656D735F746F5F7375626D6974203D206461546869732E616374696F6E2E';
wwv_flow_imp.g_varchar2_table(17) := '61747472696275746530323B0D0A0D0A0D0A20202020202020202F2F204150455820416A61782043616C6C0D0A2020202020202020617065782E7365727665722E706C7567696E28765F416A61784964656E7469666965722C207B0D0A0D0A2020202020';
wwv_flow_imp.g_varchar2_table(18) := '202020202020207830313A2020765F6F75747075745F66696C656E616D652C0D0A202020202020202020202020200D0A202020202020202020202020706167654974656D733A20765F6974656D735F746F5F7375626D6974202F2F222350315F44455054';
wwv_flow_imp.g_varchar2_table(19) := '4E4F2C2350315F454D504E4F222C2074656D706C6174650D0A0D0A20202020202020207D2C207B0D0A202020202020202020202020737563636573733A2066756E6374696F6E20284461746146726F6D416A617829207B0D0A0D0A202020202020202020';
wwv_flow_imp.g_varchar2_table(20) := '20202020202020636F6E736F6C652E6C6F67284461746146726F6D416A6178293B20202F2F2064656275670D0A2020202020202020202020202020200D0A0D0A20202020202020202020202020202020242827626F647927292E74726967676572282763';
wwv_flow_imp.g_varchar2_table(21) := '6172626F6E6974612D7265706F72742D726563656976656427293B0D0A0D0A2020202020202020202020202020202076617220785F7265706F72745F6D696D6574797065203D204461746146726F6D416A61782E7265706F727467656E6572617465642E';
wwv_flow_imp.g_varchar2_table(22) := '6D696D65747970653B0D0A2020202020202020202020202020202076617220785F7265706F72745F626173653634203D204461746146726F6D416A61782E7265706F727467656E6572617465642E6261736536343B0D0A0D0A0D0A202020202020202020';
wwv_flow_imp.g_varchar2_table(23) := '20202020202020747279207B0D0A2020202020202020202020202020202020202020766172207265706F7274626C6F62203D20636172626F6E6974615F6A732E626173653634746F426C6F6228785F7265706F72745F6261736536342C20785F7265706F';
wwv_flow_imp.g_varchar2_table(24) := '72745F6D696D6574797065293B0D0A2020202020202020202020202020202020202020696620284461746146726F6D416A61782E646F776E6C6F6164203D3D3D20276A732729207B0D0A2020202020202020202020202020202020202020202020207361';
wwv_flow_imp.g_varchar2_table(25) := '76654173287265706F7274626C6F622C20765F6F75747075745F66696C656E616D65293B0D0A0D0A2020202020202020202020202020202020202020202020202F2F72656D6F7665207370696E6E65720D0A202020202020202020202020202020202020';
wwv_flow_imp.g_varchar2_table(26) := '2020202020207370696E6E65722E72656D6F766528293B0D0A20202020202020202020202020202020202020207D0D0A202020202020202020202020202020207D20636174636820286572726F7229207B0D0A2020202020202020202020202020202020';
wwv_flow_imp.g_varchar2_table(27) := '202020636F6E736F6C652E6C6F6728276572726F722066696C6527293B0D0A2020202020202020202020202020202020202020636F6E736F6C652E6C6F67286572726F72293B0D0A20202020202020202020202020202020202020207370696E6E65722E';
wwv_flow_imp.g_varchar2_table(28) := '72656D6F766528293B0D0A202020202020202020202020202020207D0D0A0D0A2020202020202020202020207D2C0D0A2020202020202020202020206572726F723A2066756E6374696F6E20287868722C20704D65737361676529207B0D0A2020202020';
wwv_flow_imp.g_varchar2_table(29) := '20202020202020202020202F2F72656D6F7665207370696E6E65720D0A202020202020202020202020202020207370696E6E65722E72656D6F766528293B0D0A202020202020202020202020202020202F2F206164642061706578206576656E740D0A20';
wwv_flow_imp.g_varchar2_table(30) := '202020202020202020202020202020242827626F647927292E747269676765722827636172626F6E6974612D7265706F72742D6572726F722D303127293B0D0A202020202020202020202020202020202F2F206C6F6767696E670D0A2020202020202020';
wwv_flow_imp.g_varchar2_table(31) := '2020202020202020636F6E736F6C652E6C6F672827646F7468656A6F623A20617065782E7365727665722E706C7567696E204552524F523A272C20704D657373616765293B0D0A202020202020202020202020202020202F2F2063616C6C6261636B2829';
wwv_flow_imp.g_varchar2_table(32) := '3B0D0A2020202020202020202020207D0D0A20202020202020207D293B0D0A0D0A202020207D0D0A7D';
null;
end;
/
begin
wwv_flow_imp_shared.create_plugin_file(
 p_id=>wwv_flow_imp.id(39112921129881522724)
,p_plugin_id=>wwv_flow_imp.id(39112909937166464326)
,p_file_name=>'carbonita.js'
,p_mime_type=>'text/javascript'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_imp.varchar2_to_blob(wwv_flow_imp.g_varchar2_table)
);
end;
/
prompt --application/end_environment
begin
wwv_flow_imp.import_end(p_auto_install_sup_obj => nvl(wwv_flow_application_install.get_auto_install_sup_obj, false));
commit;
end;
/
set verify on feedback on define on
prompt  ...done
