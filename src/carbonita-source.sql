DECLARE
/*
carbonita da v0.10.7

    Features :
        - choose format 
        - query type rows or json or autobind
        - parameters as static values
        - parameters as page items
        - use javascript to submit Page Items (otherwise we should submit page ?!)


    Known Issues :
        - if error in the query no way to know what was wrong 
        - using subtitutions in static values will not send values to server unless submitting page
        
    TODO :
        - detect binding in the query excluding comments
*/
    
    
    -- just a way to show errors
    PROCEDURE message_error (
        p_error_message IN VARCHAR2 DEFAULT NULL
    ) IS
    BEGIN
        apex_json.initialize_output(p_http_header => TRUE);
        apex_json.flush;
        apex_json.open_object;
        apex_json.write('status', 'error');
        apex_json.write('message', p_error_message);
        apex_json.close_object;
    END message_error;

    -- get template as blob from url or ... TODO
    PROCEDURE carbonita_pkg_get_report_template (
        p_template_static     IN VARCHAR2,
        p_app_id              IN NUMBER DEFAULT v('APP_ID'),
        out_template_blob     OUT BLOB,
        out_template_mimetype OUT VARCHAR2
    ) AS
    BEGIN
        SELECT
            blob_content,
            mime_type
        INTO
            out_template_blob,
            out_template_mimetype
        FROM
            apex_application_files
        WHERE
                file_type = 'STATIC_FILE'
            AND flow_id = p_app_id
            AND filename = p_template_static;

    EXCEPTION
        WHEN no_data_found THEN
            out_template_blob := NULL;
            out_template_mimetype := NULL;
    END carbonita_pkg_get_report_template;

    -- call nodejs server to generate report from template and data 
    PROCEDURE carbonita_pkg_generate_report (
        p_template_blob     IN BLOB,
        p_template_mimetype IN VARCHAR2 DEFAULT 'plain/txt',
        p_report_data       IN CLOB, -- json data to send
        p_report_name       IN VARCHAR2 DEFAULT 'result', -- report name
        p_report_type       IN VARCHAR2 DEFAULT 'pdf', -- report type
        p_url               IN VARCHAR2,--DEFAULT const_nodejs_url,-- nodejs server url where to  POST

        out_blob            OUT BLOB,-- generated report as blob
        out_mimetype        OUT VARCHAR2,
        out_filename        OUT VARCHAR2,
        out_size            OUT NUMBER --??             
    ) AS
        l_req_multipart      apex_web_service.t_multipart_parts;
        l_response_blob      BLOB;
        l_template_mime_type VARCHAR2(250);
        l_res_object         json_object_t;
    BEGIN

        -- TEST just for test outside apex 
        -- TEST apex_util.set_security_group_id (p_security_group_id => 0); -- use schema security group

        apex_web_service.g_request_headers.DELETE();
        apex_web_service.set_request_headers(p_name_01 => 'Content-Type', p_value_01 => 'application/json', p_name_02 => 'User-Agent'
        , p_value_02 => 'APEX', p_reset => FALSE,
                                            p_skip_if_exists => TRUE);

        apex_web_service.append_to_multipart(p_multipart => l_req_multipart, p_name => 'report_type', p_body => p_report_type);

        apex_web_service.append_to_multipart(p_multipart => l_req_multipart, p_name => 'report_name', p_body => p_report_name);

        apex_web_service.append_to_multipart(p_multipart => l_req_multipart, p_name => 'req_encoding', p_body => 'binary');

        apex_web_service.append_to_multipart(p_multipart => l_req_multipart, p_name => 'data_text', p_body => p_report_data);

        apex_web_service.append_to_multipart(p_multipart => l_req_multipart, p_name => 'template_binary', p_body_blob => p_template_blob
        );

        l_response_blob := apex_web_service.make_rest_request_b(p_url => p_url, p_http_method => 'POST', p_body_blob => apex_web_service.generate_request_body
        (l_req_multipart));

        l_res_object := NEW json_object_t;
        FOR i IN 1..apex_web_service.g_headers.count LOOP
            l_res_object.put(apex_web_service.g_headers(i).name, apex_web_service.g_headers(i).value);
        END LOOP;

        out_blob := l_response_blob;
        out_mimetype := l_res_object.get_string('Content-Type');
        out_filename := p_report_name;
        out_size := NULL;
    EXCEPTION
        WHEN OTHERS THEN
            message_error('generate report');
    END carbonita_pkg_generate_report;


    -- get data as json from query with/without parameters
    FUNCTION carbonita_pkg_get_data_clob ( -- with parameter
        p_query       IN VARCHAR2 DEFAULT q'# select JSON_ARRAYAGG(json_object(ename,job)) val from emp where :e1 = :e2 #',
        p_query_type       IN VARCHAR2 DEFAULT 'json',
        p_parameter_values IN apex_t_varchar2,
        p_separator        IN VARCHAR2 
    ) RETURN CLOB AS
        l_return_clob      CLOB;
        l_dyn_cursor       NUMBER;    
        l_dummy            PLS_INTEGER;
        l_cursor           SYS_REFCURSOR;
        l_context apex_exec.t_context;
            /* j apex_json.t_values;
            l_e   json_element_t; 
             l_json json_object_t;  */
        l_bind_query_count INTEGER;
        l_bind_val_count   INTEGER;
        binding_name_array dbms_sql.varchar2_table;
    BEGIN
    /*
        if query binding count != parameters count then error
        query type : json , rows, autobind
    */
    if p_query_type in ( 'json','rows') then
        BEGIN
        -- check number of input parameters vs query binding
        l_bind_query_count := regexp_count(p_query, '(:[[:alnum:]_]+)');
        l_bind_val_count := p_parameter_values.count;
        
        IF l_bind_query_count > 0 and l_bind_query_count != l_bind_val_count THEN 
            --raise_application_error(-20000, 'Number of placeholders does not match number of parameter values');
            return '{"error":"error binding count !"}'; 
        END IF;
    
    -- loop over placeholders and get binding variable names from query
    -- TODO exclude binding in comment
        FOR i IN 1..l_bind_query_count LOOP
            binding_name_array(i) := regexp_substr(p_query, '(:[[:alnum:]_]+)', 1, i);
        END LOOP;
                l_dyn_cursor := dbms_sql.open_cursor;
                dbms_sql.parse(l_dyn_cursor, p_query, dbms_sql.native);

                -- bind variable by name 
                IF l_bind_val_count > 0 THEN
                    FOR i IN 1..l_bind_val_count LOOP
                        dbms_sql.bind_variable(l_dyn_cursor, binding_name_array(i), p_parameter_values(i));
                    END LOOP;
                END IF;

            IF  p_query_type =  'json' THEN 
                -- assuming query return one column as json array result
                dbms_sql.define_column(l_dyn_cursor, 1, l_return_clob);
                l_dummy := dbms_sql.execute_and_fetch(l_dyn_cursor);
                dbms_sql.column_value(l_dyn_cursor, 1, l_return_clob); 

                -- close the cursor
                dbms_sql.close_cursor(l_dyn_cursor);
                
            else --if p_query_type =  'rows' then
                
                l_dummy := dbms_sql.execute(l_dyn_cursor);
                
                -- converting to sysrefcursor
                l_cursor := dbms_sql.to_refcursor(l_dyn_cursor);
                
                -- use apex.write to write sysrefcursor to json clob
                dbms_lob.createtemporary(l_return_clob, FALSE);
                apex_json.initialize_clob_output(p_preserve => TRUE);
                --test apex_json.open_object;
            apex_json.write( l_cursor);-- signature 7
            -- apex_json.write( 'd' , l_cursor);-- signature 14
                --test apex_json.close_object;
                dbms_lob.copy(l_return_clob, apex_json.get_clob_output, dbms_lob.getlength(apex_json.get_clob_output));
                apex_json.free_output;
                
                -- apex_write should close l_cursor , but ..? 
                if l_cursor%ISOPEN then 
                    CLOSE l_cursor;
                end if;
                
            
            END IF;
        END;

        else --if p_query_type =  'autobind' then
                
            begin
                l_context := apex_exec.open_query_context( 
                                p_location   => apex_exec.c_location_local_db,
                                p_sql_query  => p_query );
                dbms_lob.createtemporary(l_return_clob, FALSE);
                apex_json.initialize_clob_output(p_preserve => TRUE);
                    apex_json.write_context(  p_context => l_context);
             
                
                -- write result to the clob
                dbms_lob.copy(l_return_clob, apex_json.get_clob_output, dbms_lob.getlength(apex_json.get_clob_output));
                apex_json.free_output;

               -- dbms_lob.freetemporary( L_RETURN_CLOB );


            end;    
        end if ;    

        --RETURN l_return_clob;
         RETURN coalesce(l_return_clob,'{}');
    EXCEPTION
        WHEN OTHERS THEN
            IF dbms_sql.is_open(l_dyn_cursor) THEN
                dbms_sql.close_cursor(l_dyn_cursor);
            END IF;
            --message_error('Error Generate Data');
            RETURN '{"error":"Error retrieve data from query"}';
    END carbonita_pkg_get_data_clob;

    -- da plugin render
    FUNCTION carbonita_plugin_da_render (
        p_dynamic_action IN apex_plugin.t_dynamic_action,
        p_plugin         IN apex_plugin.t_plugin
    ) RETURN apex_plugin.t_dynamic_action_render_result AS

        l_da_render_result    apex_plugin.t_dynamic_action_render_result;
        
        l_server_url          VARCHAR2(4000) := p_plugin.attribute_01;
        
        l_report_filename     VARCHAR2(4000) := p_dynamic_action.attribute_04;
        
        l_query               VARCHAR2(4000) := p_dynamic_action.attribute_01;
        l_query_type          VARCHAR2(4000) := p_dynamic_action.attribute_10;
        
        
        
        l_template_type       VARCHAR2(4000) := p_dynamic_action.attribute_15;
        -- not used l_template_static    VARCHAR2(4000) := p_dynamic_action.attribute_02; 
        l_template_PageItem    VARCHAR2(4000) := p_dynamic_action.attribute_05;
            
        
        l_output_format_attr_type  VARCHAR2(4000) := p_dynamic_action.attribute_07;
        l_output_format_value       VARCHAR2(4000) := p_dynamic_action.attribute_03;
        l_output_format_item  VARCHAR2(4000) := p_dynamic_action.attribute_06;

        l_binding_attr_type        VARCHAR2(4000) := p_dynamic_action.attribute_11;
        -- not used in render l_binding_static      varchar2(4000) := p_dynamic_action.attribute_12; -- not used in render
        l_binding_PageItems   varchar2(4000) := p_dynamic_action.attribute_13;
        

        l_pageitems_to_submit VARCHAR2(4000);


    BEGIN
        apex_plugin_util.debug_dynamic_action(p_plugin => p_plugin, p_dynamic_action => p_dynamic_action);
        apex_javascript.add_library(p_name => 'FileSaver', p_directory => p_plugin.file_prefix, p_check_to_add_minified => TRUE);

        apex_javascript.add_library(p_name => 'carbonita', p_directory => p_plugin.file_prefix, p_check_to_add_minified => FALSE);

        l_da_render_result.javascript_function := 'carbonita_js.carbonita_function';
        l_da_render_result.ajax_identifier := apex_plugin.get_ajax_identifier; 

        -- prepare PageItems variables (Used for binding, format, template) to be submited in apex.server.plugin ... pageItems
        begin
            -- convert PageItems from  "P1_DEPTNO,P1_EMPNO" to "#P1_DEPTNO,#P1_EMPNO
            -- COMMENT : we just use items names , so do we need to check  ?
            
            l_pageitems_to_submit := '';        
            
            IF l_binding_attr_type = 'PageItems' THEN
                -- if no_data_found then it must be not PageItems
                SELECT LISTAGG('#' || column_value, ',') WITHIN GROUP( ORDER BY 1 )
                    INTO l_pageitems_to_submit
                FROM TABLE ( apex_string.split(l_binding_PageItems, ',') );
            END IF;
            
            IF l_template_type = 'PageItem'   THEN
                l_pageitems_to_submit :=  l_pageitems_to_submit || ',' 
                        || ' #' || l_template_PageItem;
            END IF; 
        
            if l_query_type= 'autobind' then ---- send item in query autobind
                        -- TODO optimize this slowbyslow 
                        -- TODO check for security issues
                FOR i IN 1..regexp_count(l_query, '(:[[:alnum:]_]+)') LOOP
                    l_pageitems_to_submit :=  l_pageitems_to_submit || ',' 
                        || '#'|| REGEXP_SUBSTR(l_query, '(:([[:alnum:]_]+))', 1, i, NULL, 2);
                END LOOP;
            end if;
            
            if l_output_format_attr_type = 'PageItem'   then
                l_pageitems_to_submit := l_pageitems_to_submit || ',' 
                        || '#' || l_output_format_item ;
            end if; 
            
            l_pageitems_to_submit := REGEXP_SUBSTR(l_pageitems_to_submit, '[^,].*');
 
            
        end; -- prepare PageItems variables
        
        -- Parameters sent to carbonita_js
        l_da_render_result.attribute_01 := l_report_filename;
        l_da_render_result.attribute_02 := l_pageitems_to_submit; -- //"#P1_DEPTNO,#P1_EMPNO"

        RETURN l_da_render_result;
    END carbonita_plugin_da_render;

    -- da plugin ajax : 
    FUNCTION carbonita_plugin_da_ajax (
        p_dynamic_action IN apex_plugin.t_dynamic_action,
        p_plugin         IN apex_plugin.t_plugin
    ) RETURN apex_plugin.t_dynamic_action_ajax_result AS

        l_da_ajax_result            apex_plugin.t_dynamic_action_ajax_result;
        
        l_plg_server_url                VARCHAR2(250) := p_plugin.attribute_01;
        l_plg_separator                 VARCHAR2(250) := p_plugin.attribute_02;
        
        l_report_name_attr              VARCHAR2(250) := p_dynamic_action.attribute_04; --apex_application.g_x01;
        l_debug_submited_items          VARCHAR2(4000) := apex_application.g_x02;
        
        
        l_query_da_attr                 VARCHAR2(4000) := p_dynamic_action.attribute_01;
        l_query_da_attr_type            VARCHAR2(4000) := p_dynamic_action.attribute_10;
        l_query_data_clob               CLOB;
        
        
        l_template_da_attr_Type         VARCHAR2(250)   := p_dynamic_action.attribute_15;
        l_template_da_attr_Static       VARCHAR2(250)   := p_dynamic_action.attribute_02;
        l_template_da_attr_PageItem     VARCHAR2(250)   := p_dynamic_action.attribute_05;
        l_template_out_blob             BLOB;           -- generated blob from template url
        l_template_out_mimetype         VARCHAR2(250);
        
        
        l_output_format_value           VARCHAR2(250)  ;
        l_output_format_attr_type       VARCHAR2(4000) := p_dynamic_action.attribute_07;
        l_output_format_attr_Static     VARCHAR2(4000) := p_dynamic_action.attribute_03;
        l_output_format_attr_PageItem   VARCHAR2(4000) := p_dynamic_action.attribute_06;
        

        l_binding_attr_type             VARCHAR2(4000) := p_dynamic_action.attribute_11;
        l_binding_attr_Static           varchar2(4000) := p_dynamic_action.attribute_12;
        l_binding_attr_PageItems        varchar2(4000) := p_dynamic_action.attribute_13;
        l_binding_values                apex_t_varchar2;
        
        
        l_generated_filename            VARCHAR2(255);
        l_generated_mimetype            VARCHAR2(255);
        l_generated_blob                BLOB;
        l_generated_size                NUMBER;
        
    BEGIN
        
        begin -- retrieve template as blob
        carbonita_pkg_get_report_template(
            p_template_static   => CASE l_template_da_attr_Type
                                        WHEN 'Static'   THEN l_template_da_attr_Static
                                        WHEN 'PageItem' THEN v(l_template_da_attr_PageItem)
                                    END, 
            p_app_id            => :APP_ID, 
            
                out_template_blob       => l_template_out_blob, 
                out_template_mimetype   => l_template_out_mimetype
                );
        end;
        
        
        
        BEGIN -- prepare binding from plugin attribut (unless autobind there will be no need to )
            
            -- TODO check if binding exists in the query     
            l_binding_values := apex_t_varchar2();
            
            -- set l_binding_values depending on l_binding_attr_type 
            CASE l_binding_attr_type
                
                WHEN 'Static' THEN -- get binding values from plugin attributes
                    FOR c IN ( SELECT column_value binding_values 
                              FROM TABLE ( apex_string.split(l_binding_attr_static, l_plg_separator))  ) LOOP
                        apex_string.push(l_binding_values, c.binding_values);
                    END LOOP;
                            
                WHEN 'PageItems' THEN -- get bindigs values from items listed in plugin attributese
                    FOR c IN (  SELECT column_value page_items_values 
                                -- TODO check if better to use sys_context('APEX$SESSION',column_value) 
                                 FROM   TABLE ( apex_string.split(l_binding_attr_PageItems, ',') ) ) LOOP
                        apex_string.push(l_binding_values, v(c.page_items_values));
                    END LOOP;
                
            END CASE;

        EXCEPTION
            WHEN OTHERS THEN  message_error('Error binding');
            
        END;

         
        BEGIN -- retrieve data as json clob
            l_query_data_clob := carbonita_pkg_get_data_clob(
                p_query             => l_query_da_attr, 
                p_query_type        => l_query_da_attr_type, 
                p_parameter_values  => l_binding_values, 
                p_separator         => l_plg_separator
                );
        EXCEPTION
            WHEN OTHERS THEN
                message_error('Error  generate data clob');
                
        END;

        
        BEGIN -- send data and template to nodejs-carbonita ; retrieve generated report
        if l_output_format_attr_type = 'PageItem'    
            then l_output_format_value := nvl(v(l_output_format_attr_PageItem) ,'pdf') ;
            else l_output_format_value := nvl(l_output_format_attr_Static,'pdf');
        end if; 

            
            
            carbonita_pkg_generate_report(
                    p_url           => l_plg_server_url, 
                    p_report_name   => l_report_name_attr,
                    
                    p_template_blob     => l_template_out_blob, 
                    p_template_mimetype => l_template_out_mimetype, 
                    
                    p_report_data => l_query_data_clob, 
                    
                    p_report_type => l_output_format_value, 
                    
                        out_blob        => l_generated_blob, 
                        out_mimetype    => l_generated_mimetype, 
                        out_filename    => l_generated_filename, 
                        out_size    => l_generated_size);

        EXCEPTION
            WHEN OTHERS THEN
                message_error('Error  generate report');
                dbms_lob.freetemporary( l_query_data_clob );
        END;

        
        BEGIN -- send back to js ajax call , used by filesaver in  js
            apex_json.initialize_output(p_http_header => TRUE);
            apex_json.flush;
            apex_json.open_object;
                apex_json.write('status', 'success');
                apex_json.write('download', 'js');
                 -- debug
                apex_json.open_object('debug');
                    apex_json.write('format value'      ,l_output_format_value);
                    apex_json.write('format type '      ,l_output_format_attr_type);
                    apex_json.write('submited items '   ,l_debug_submited_items);
                apex_json.close_object;
                
                
                --apex_json.write('data', l_query_data_clob); --debug
                apex_json.open_object('reportgenerated');
                    apex_json.write('mimetype', l_generated_mimetype);
                    apex_json.write('filename', l_generated_filename);
                    apex_json.write('base64', apex_web_service.blob2clobbase64(l_generated_blob));--  'SGVsbG8gV29ybGQ='); 
                apex_json.close_object;
            apex_json.close_object;
        END;

        RETURN l_da_ajax_result;
    EXCEPTION
        WHEN OTHERS THEN
            raise_application_error(-20000, 'Error Occured: ' || sqlerrm);
            
            
    END carbonita_plugin_da_ajax;
    begin null; end;