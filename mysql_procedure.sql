###################################################################################
# a procedure to split a column into rows using a delimiter
###################################################################################

#schema sql
CREATE TABLE sometbl (ID INT, NAME VARCHAR(50));
insert into sometbl values
(1,'Smith'),(2,'Julio|Jones|Falcons'),(3,'White|Snow'),
(4,'Paint|It|Red'),(5,'Green|Lantern'),(6,'Brown|Bag');


#query sql for a procedure to split a column into rows using a delimiter
select * from sometbl;

delimiter //
create procedure split_column_into_rows()
    begin
        #declare variables
        declare cursor_id INT;
        declare cursor_name VARCHAR(50);
		declare finished INT;                                           
        declare n INT;
        declare i INT;
		declare name_from_pipedname_col VARCHAR(50);
        
        #declare cursor to read row by row                                   
        declare sometbl_cursor cursor for select * from sometbl;
		DECLARE CONTINUE HANDLER FOR NOT FOUND SET finished = 1;
        
        #create temporary table to store final data
        create temporary table tmp_table(ID INT, NAME VARCHAR(50));

		open sometbl_cursor;
        
        fetch_loop: loop
			fetch sometbl_cursor into cursor_id, cursor_name;
            if finished then leave fetch_loop; 
            end if;
                                                              
            set n = (select length(cursor_name) - length(replace(cursor_name,'|',''))+1);
			set i = 1;
            #run loop as many times names are there in piped NAME column - i.e. get each name and insert in a new row
			while i <= n do
		  		set name_from_pipedname_col = (select replace(substring(substring_index(cursor_name,'|',i),length(substring_index(cursor_name,'|',i - 1)) + 1),'|',''));
				insert into tmp_table values (cursor_id, name_from_pipedname_col);
			    set i = i + 1;
			end while;
        end loop;
        
        close sometbl_cursor;
                                               
        select * from tmp_table;
    end//

delimiter ;
call split_column_into_rows();