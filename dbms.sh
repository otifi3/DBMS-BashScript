#! /bin/bash
while true
do
    echo "Choose an option:"
    echo "1) Connect to DB"
    echo "2) Create DB"
    echo "3) Drop DB"
    echo "4) List DBs"
    echo "5) Exit"
    read -p "Enter your choice: " n

    case $n in
        1)
			echo ""
            ls -p | grep "/" | sed 's:/$::'
            echo ""
            read -p "Enter DB Name: " db
			if [[ "$db" == *"/"* ]] || [[ "$db" == "."* ]] || [[ -z "$db" ]]
			then
			echo ""
			echo "Data Base Does not exist"
			echo ""
			else
				if cd "$db" 2>/dev/null
				then
					while true
					do
						echo ""	
						echo "Connected to database: $db"
						
						echo "Choose an option:"
						echo "1)Create Table			2)List Tables		3)Drop Table "
						echo "4)Select From Table		5)Insert Record		6)Update Record"
						echo "7)Delete Record 		8)Back"
						echo ""
						read -p "Enter your choice: " n

						case $n in
							1)
								echo ""
								read -p "Enter Table Name: " name
								if [[ "$name" == *"/"* ]] || [[ "$name" == "."* ]] || [[ -z "$name" ]] || [[ "$name" =~ ^[0-9_] ]]
								then
									echo ""
									echo "Table Name Violation"
									echo ""
									continue
								fi
								if [[ -e $name ]]
								then
									echo ""
									echo "Table ${name} already exists. Please choose a different name."
									echo ""
									continue
								fi
								flag_tb=0
								if [[ "$name" =~ \
								^([sS][eE][lL][eE][cC][tT]|[fF][rR][oO][mM]|[wW][hH][eE][rR][eE]|[dD][eE][lL][eE][tT][eE]| \ 
								[dD][rR][oO][pP]|[iI][nN][sS][eE][rR][tT]|[uU][pP][dD][aA][tT][eE])$ ]]
								then
									flag_tb=1
								fi
								if [[ "$flag_tb" -eq 1 ]]
								then
									echo ""
									echo "table name violation"
									echo ""
									continue 
								fi
							
								read -p "Enter Columns Number: " cols
								if [[ ! "$cols" =~ ^[1-9][0-9]*$ ]] || [[ -z $cols ]]
								then
									echo ""
									echo "Column Number Violation"
									echo ""
									continue
								fi
								if [[ "$cols" == "0" ]]
								then
									echo ""
									echo "Can not create tabel with 0 columns"
									echo ""
									continue
								fi
								echo "Primary key will the first column"
								arr_cols=()
								arr_typs=()
								declare -A col_dup
								flag_c=0
								flag_t=0
								flag_d=0
								item_cols=""
								item_types=""
								for (( col=1; col<=cols; col++ ))
								do
									read -p "Enter Column ${col} Name: " col_name
									read -p "Enter Column ${col} type (string, number): " typ
									if [[ "$col_name" =~ ^[0-9:'"']['"':]['"':]$ ]] || [[ -z $col_name ]]
									then 
										flag_c=1
										break
									fi
									if [[ "$col_name" =~ \
									^([sS][eE][lL][eE][cC][tT]|[fF][rR][oO][mM]|[wW][hH][eE][rR][eE]|[dD][eE][lL][eE][tT][eE]| \ 
									[dD][rR][oO][pP]|[iI][nN][sS][eE][rR][tT]|[uU][pP][dD][aA][tT][eE])$ ]]
									then
										flag_c=1
										break
									fi

									if [[ "$typ" != "number" && "$typ" != "string" ]]
									then
										flag_t=1
									fi
									arr_cols+=("$col_name")
									arr_typs+=("$typ")
								done
									
								if [[ "$flag_c" -eq 1 ]]
								then
									echo ""
									echo "column name violation"
									echo ""
									continue 
								fi
								if [[ "$flag_t" -eq 1 ]]
								then
									echo ""
									echo "column type violation"
									echo ""
									continue 
								fi
							
								for item in "${arr_cols[@]}"
								do
									if [[ flag_d -eq 1 ]]
									then
										break
									fi
									if [[ ${col_dup[$item]} ]]
									then
													flag_d=1
										fi
										col_dup["$item"]=1
								done
				
								if [[ $flag_d -eq 1 ]]
								then
									echo ""
									echo "column name duplication violation"
									echo ""
									continue
								fi
				
								touch "$name"
								touch "${name}-meta"
							
								for (( i=0; i<${#arr_cols[@]}; i++ ))
								do
									if [ $i -eq 0 ]
									then
										item_cols="${arr_cols[$i]}"
									else
										item_cols="${item_cols}:${arr_cols[$i]}"
									fi
								done
								for (( i=0; i<${#arr_typs[@]}; i++ ))
								do
									if [ $i -eq 0 ]
									then
										item_types="${arr_typs[$i]}"
									else
										item_types="${item_types}:${arr_typs[$i]}"
									fi
								done
							
								echo "$item_cols" > "$name"
								echo "$item_types" > "${name}-meta"

								echo ""
								echo "Table ${name} Created with ${cols} columns"
								echo ""
								;;
								
							2)
								echo ""
								ls | grep -v '\-meta$'
								echo ""
								;;
							3)	
								echo ""
								ls | grep -v '\-meta$'
								echo ""
								read -p "Enter table Name to Remove: " name
								if [ -f "$name" ] && [[ ! "$name" == *"/"* ]] && [[ ! "$name" == "."* ]]
								then 
									rm "$name"
									rm "${name}-meta"
									echo ""
									echo "Table ${name} Droped"
								else 
									echo "This table does not exist"
								fi
								echo ""
								;;
							4)
								echo ""
								ls | grep -v '\-meta$' | tr '\n' ' '
								echo ""
								read -p "Enter Table Name: " table_name
								if [[ -z $table_name ]] || [[ "$table_name" == *"/"* ]] || [[ "$table_name" == "."* ]]
								then
									echo "" 
									echo "table does not exist"
									echo ""
									continue
								elif [ -f "$table_name" ]
								then
									read -p "Enter type of Selection(all/cond): " typ
								else
									echo ""
									echo "table does not exist"
									echo ""
									continue
								fi

								if [[ "$typ" == "all" ]]
								then
									cat "$table_name"
								elif [[ "$typ" == "cond" ]]
								then
									echo ""
									awk -F ':' 'NR==1 { gsub(":", " "); print }' "$table_name"
									read -p "Enter column: " col_name
									read -p "Enter operator (==, !=, <, >, <=, >=): " operator
									read -p "Enter value: " value

									header=$(head -n 1 "$table_name")
									index=1
									flag_cf=0
									IFS=':'
									for col in $header 
									do
										if [[ "$col" == "$col_name" ]]
										then
											col_number=$index
											flag_cf=1
											break
										fi
										index=$((index+1)) 
									done
									unset IFS

									if [[ $flag_cf -eq 0 ]]
									then
										echo "Column not found!"
									elif [[  $operator != "==" && $operator != "!=" && $operator != "<" && $operator != ">" && $operator != "<=" && $operator != ">="  ]]
									then
										echo "Symbol Violation"
									else
										echo ""
										head -n 1 "$table_name"
										awk -F ':' -v col="$col_number" -v op="$operator" -v val="$value" '
										NR > 1 {
											col_value = $col
											if ((op == "==" && col_value == val) ||
											(op == "!=" && col_value != val) ||
											(op == "<" && col_value < val) ||
											(op == ">" && col_value > val) ||
											(op == "<=" && col_value <= val) ||
											(op == ">=" && col_value >= val)) {
											print $0
											}
										}
										' "$table_name"
									fi
								else
									echo ""
									echo "Invalid Option"
									echo ""
								fi
									
								;;
							5)
								echo ""
								ls | grep -v '\-meta$' | tr '\n' ' '
								echo ""
								read -p "Enter Table Name to Insert Into: " tb
								if [ -z $tb ]
								then
									echo ""
									echo "Table does not exist"
									echo ""
									continue
								fi
								if [ -f "$tb" ] || [[ !"$tb" == *"/"* ]] || [[ !"$tb" == "."* ]]
								then 
									echo ""
									num_cols=$(awk -F ':' '{print NF; exit}' "$tb")
									flag_pk=0
									flag_typ=0
									echo "First Column is the PK"
									row=""

									for i in $(seq 1 "$num_cols")
									do
										col_type=$(awk -F ':' -v col="$i" 'NR==1 {print $col}' "${tb}-meta")
										echo "Column $i type: $col_type"
										read -p "Enter value for column $i: " value
									
										if [[ $flag_typ -eq 1 ]]
										then
											echo ""
											echo "type Insertion Violation"
											echo ""
											break
										fi
										if [[ $flag_pk -eq 1 ]]
										then 
											echo ""
											echo "PK Violation"
											echo ""
											break 
										fi
									
										if [[ $i -eq 1 ]]
										then		
											flag_pk=$(awk -F ':' -v val="$value" '$1 == val {print 1}' "$tb")
											row="$value"
										else
											row="${row}:$value"
										fi
									
										if [[ $col_type == "number" ]] && [[ "$value" =~ ^[0-9][0-9]*$ ]]
										then
											flag_typ=0
										elif [[ $col_type == "string" ]] && [[ !("$value" == *":"* || "$value" == *"'"* || "$value" == *'"'*) ]]
										then
											flag_typ=0
										else
											flag_typ=1
											echo ""
											echo "type Insertion Violation for column $i."
											echo ""
											break
										fi
										
									done

									if [[ $flag_typ -ne 1 ]] && [[ $flag_pk -ne 1 ]]
									then
										echo "$row" >> "$tb"
										echo ""
										echo "Record Inserted"
									fi
								else
									echo ""
									echo "Table Does Not Exist"
									echo""
								fi
								;;
							6)
								echo ""
								ls | grep -v '\-meta$' | tr '\n' ' '
								echo ""
								read -p "Enter Table Name: " table_name
								if [[ -z "$table_name" ]]
								then 
									echo -e "Table Does not Exist"
									continue
								fi
								if [[ ! -f "$table_name" ]] || [[ "$table_name" =~ [/\:] ]] || [[ "$table_name" == .* ]]
								then
									echo "Table does not exist or invalid table name!"
									continue
								fi

								awk -F ':' 'NR==1 { gsub(":", " "); print }' "$table_name"
								read -p "Enter column for condition: " cond_col_name
								read -p "Enter operator (==, !=, <, >, <=, >=): " operator
								if [[ ! "$operator" =~ ^(==|!=|<|>|<=|>=)$ ]]
								then
									echo ""
									echo "Invalid operator"
									echo ""
									continue
								fi
								
								read -p "Enter value for condition: " cond_value
								echo ""
								awk -F ':' 'NR==1 { gsub(":", " "); print }' "$table_name"
								read -p "Enter column to update: " update_col_name
								read -p "Enter new value for column: " new_value

								header=$(head -n 1 "$table_name")
								pk_col=$(awk -F ':' 'NR==1 {print $1}' "$table_name")
								index=1
								cond_flag=0
								update_flag=0
								pk_flag=0
								IFS=':'

								if [[ "$new_value" != *":"* && "$new_value" != *"'"* && "$new_value" != *'"'* ]]
								then
									v_typ="string"
								elif [[ "$new_value" =~ ^[0-9]+$ ]]
								then
									v_typ="number"
								else
									v_typ="invalid"
								fi

								for col in $header
								do
									if [[ "$col" == "$cond_col_name" ]]
									then
										cond_col_number=$index
										cond_flag=1
									fi
									if [[ "$col" == "$update_col_name" ]]
									then
										update_col_number=$index
										update_flag=1
									fi
									if [[ "$col" == "$pk_col" ]] && [[ "$col" == "$update_col_name" ]]
									then
										pk_flag=1
									fi
									index=$((index+1)) 
								done

								tb_typ=0
								tb_typ=$(cut -d':' -f"$update_col_number" "${table_name}-meta")

								if [[ $cond_flag -eq 0 ]]
								then
									echo "Condition column not found!"
								elif [[ $update_flag -eq 0 ]]
								then
									echo "Update column not found!"
								elif [[ $pk_flag -eq 1 ]]
								then
									echo "Update PK is not allowed"
								elif [[ "$tb_typ" == "$v_typ" ]]
								then
									awk -F ':' -v cond_col="$cond_col_number" -v val="$cond_value" -v op="$operator" -v update_col="$update_col_number" -v new_val="$new_value" '
									{
									if (NR == 1) {
										# Print the header row as is
										print $0
										next
									}
									if (NF == 0) next
									col_value = $cond_col

									if ((op == "==" && col_value == val) ||
										(op == "!=" && col_value != val) ||
										(op == "<" && col_value < val) ||
										(op == ">" && col_value > val) ||
										(op == "<=" && col_value <= val) ||
										(op == ">=" && col_value >= val)) {
										$update_col = new_val
									}
									row = $1
									for (i = 2; i <= NF; i++) {
										row = row ":" $i
									}
									print row
								}
									' "$table_name" > "$table_name.tmp" && mv "$table_name.tmp" "$table_name" && echo "Matching rows updated"
								if [[ -f "$table_name.tmp" ]]
								then
									rm "$table_name.tmp"
								fi
								else
									echo ""
									echo "Type violation"
								fi
								;;

							7)
								echo ""
								ls | grep -v '\-meta$' | tr '\n' ' '
								echo ""
								read -p "Enter Table Name To Delete From: " table_name
								if [[ -z "$table_name" ]]
								then
									echo ""
									echo "Table Does Not Exist"
									echo ""
									continue
								elif [[ -f "$table_name" ]] || [[ ! "$table_name" == *"/"* ]] || [[ ! "$table_name" == "."* ]]
								then
									read -p "Enter type of Deletion (all/cond): " typ
									if [[ "$typ" == "all" ]]
									then
										head -n 1 "$table_name" > temp && mv temp "$table_name"
										echo "All records Deleted"
									elif [[ "$typ" == "cond" ]]
									then
										awk -F ':' 'NR==1 { gsub(":", " "); print }' "$table_name"

										read -p "Enter column: " col_name
										read -p "Enter operator (==, !=, <, >, <=, >=): " operator
										read -p "Enter value: " value

										header=$(head -n 1 "$table_name")
										index=1
										flag_cf=0
										IFS=':'
										for col in $header
										do
											if [[ "$col" == "$col_name" ]]
											then
												col_number=$index
												flag_cf=1
												break
											fi
											index=$((index + 1))
										done
										unset IFS

										if [[ $flag_cf -eq 0 ]]
										then
											echo "Column not found"
										elif [[ $operator != "==" && $operator != "!=" && $operator != "<" && $operator != ">" && $operator != "<=" && $operator != ">=" ]]
										then
											echo "Invalid operator"
										else
											awk -F ':' -v col="$col_number" -v op="$operator" -v val="$value" '
											BEGIN { OFS=FS }
											NR == 1 { print; next } 
											{
												col_value = $col
												# The condition should be used to decide which rows to delete (exclude matching rows)
												if ((op == "==" && col_value == val) ||
												(op == "!=" && col_value != val) ||
												(op == "<" && col_value + 0 < val + 0) ||
												(op == ">" && col_value + 0 > val + 0) ||
												(op == "<=" && col_value + 0 <= val + 0) ||
												(op == ">=" && col_value + 0 >= val + 0)) {
												# Skip rows that match the condition
												next
												}
												# Print the remaining rows
												print $0
											}' "$table_name" > "$table_name.tmp" && mv "$table_name.tmp" "$table_name" && echo "Matching Rows Deleted."
										fi

									else
										echo ""
										echo "Invalid Option"
										echo ""
									fi
									
								else
									echo ""
									echo "Table Dose Not Exist"
									echo ""
								fi			
								;;
							8)
								cd ..
								break
								;;
							*)
								echo "Invalid option. Please try again."
								;;
						esac
					done
					
				else
					echo ""
					echo "Database $db does not exist"
					read -p "Do you want to create $db DataBase(y/n)? " yn
					if  [[ "$yn" == "y" ]]
					then 
					if [[ "$db" =~ \
					^([sS][eE][lL][eE][cC][tT]|[fF][rR][oO][mM]|[wW][hH][eE][rR][eE]|[dD][eE][lL][eE][tT][eE]| \ 
					[dD][rR][oO][pP]|[iI][nN][sS][eE][rR][tT]|[uU][pP][dD][aA][tT][eE]|[cC][rR][eE][aA][tT][eE])$ ]]
					then
						echo ""
						echo "DB Name Violation"
						echo ""
					elif [[ "$db" =~ ^[0-9_] ]]
					then
						echo ""
						echo "DB Name Violation"
						echo ""
					elif [[ "$db" == *"/"* ]] || [[ "$db" == "."* ]]
					then
						echo ""
						echo "DB Name Violation"
						echo ""
					elif [[ -d "$db" ]]
					then
						echo ""
						echo "DataBase ${db} already exists. Please choose a different name."
						echo ""
						continue
					else
						mkdir "$db"
						echo ""
						echo "DataBase $db Created"
						echo ""
					fi
					fi
					echo ""
				fi
			fi
            ;;
        2)
            echo ""
            read -p "Enter DB Name: " db
            if [[ "$db" =~ \
			^([sS][eE][lL][eE][cC][tT]|[fF][rR][oO][mM]|[wW][hH][eE][rR][eE]|[dD][eE][lL][eE][tT][eE]| \ 
			[dD][rR][oO][pP]|[iI][nN][sS][eE][rR][tT]|[uU][pP][dD][aA][tT][eE]|[cC][rR][eE][aA][tT][eE])$ ]]
			then
				echo ""
				echo "DB Name Violation"
				echo ""
				continue
			elif [[ "$db" =~ ^[0-9_] ]]
			then
				echo ""
				echo "DB Name Violation"
				echo ""
				continue
			elif [[ "$db" == *"/"* ]] || [[ "$db" == "."* ]]
			then
				echo ""
				echo "DB Name Violation"
				echo ""
				continue
			elif [[ -z "$db" ]]
			then
				echo ""
				echo "DB Name Violation"
				echo ""
			elif [[ -d "$db" ]]
			then
				echo ""
				echo "DataBase ${db} already exists. Please choose a different name."
				echo ""
				continue
			else
				mkdir "$db"
				echo ""
				echo "DataBase $db Created"
				echo ""
	    	fi
            ;;
        3)
			echo ""
			ls -p | grep "/" | sed 's:/$::'
            echo ""
            read -p "Enter DB Name To Drop: " db
			if [[ "$db" == *"/"* ]] || [[ "$db" == "."* ]] || [[ -z "$db" ]]
			then
				echo ""
				echo "DataBase ${db} does not exist"
				echo ""
				continue
            elif [[ -d "$db" ]]
			then
				rm -r "$db"
				echo ""  
				echo "DataBase $db Droped"
				echo ""    
	    	else
				echo ""
				echo "DataBase ${db} does not exist"
				echo ""
            fi
            ;;
        4)
			echo ""
			ls -p | grep "/" | sed 's:/$::'
			echo ""
            ;;
        5)
            echo ""
            echo "Thank You"
            echo ""
            break
            ;;
        *)
            echo ""
            echo "Invalid option. Please try again."
            echo ""
            ;;
    esac
done


