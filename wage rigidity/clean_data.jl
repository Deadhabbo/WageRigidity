using CSV, DataFrames

#region: Monthly data from 2020 to 2024
# Define the months array
months = ["ene", "feb", "mar", "abr", "may", "jun", "jul", "ago", "sep", "oct", "nov", "dic"]

for yy in 2020:2023
    println("Year: ", yy)
    
    # Initialize an empty DataFrame for the year
    year_data = DataFrame()

    for mm in eachindex(months)
        month = months[mm]
        println("Month: ", month)
        
        # Construct the file path for the month's data
        monthly_data_path = "_data\\_IRCMO\\$(yy)\\$(month)\\Variables.csv"
        # Construct the file path for the Ponderadores data
        ponderadores_path = "_data\\_IRCMO\\$(yy)\\$(month)\\Ponderadores.csv"
        
        println("Monthly Data Path: ", monthly_data_path)
        println("Ponderadores Path: ", ponderadores_path)

        # Check if both files exist before attempting to read
        if isfile(monthly_data_path) && isfile(ponderadores_path)
            # Read the CSV files into DataFrames
            monthly_data = CSV.read(monthly_data_path, DataFrame,delim=';')
            ponderadores_data = CSV.read(ponderadores_path, DataFrame,delim=';')
            
            # Trim spaces from column names for both DataFrames
            rename!(monthly_data, strip.(String.(names(monthly_data))))
            rename!(ponderadores_data, strip.(String.(names(ponderadores_data))))
            
            # Convert all column names to lowercase for consistency
            rename!(monthly_data, lowercase.(names(monthly_data)))
            rename!(ponderadores_data, lowercase.(names(ponderadores_data)))

            # Drop unwanted columns
            cols_to_drop = [:ro_t_1, :ho_t_1, :c_t_1, :ht_t_1]
            select!(monthly_data, Not(cols_to_drop))

            # Merge the monthly data with the Ponderadores data
            merged_data = innerjoin(monthly_data, ponderadores_data, on = [:tamano, :categoria, :sexo, :grupo])

            # If it's the first month ('ene'), initialize `year_data` with this merged DataFrame
            if mm == 1
                year_data = merged_data
            else
                # Append the merged data from other months to the DataFrame for the year
                year_data = vcat(year_data, merged_data, cols=:union)
            end
        else
            println("One or both files do not exist for month: ", month)
        end
    end

    # At this point, `year_data` contains all merged data for the year. You can process or save it as needed.
    # For example, to save the combined data for the year:
    combined_path = "_data\\_IRCMO\\$(yy)\\$(yy)_combined.csv"  # Update the path as needed
    CSV.write(combined_path, year_data)
end

#endregion 

#region: year data from 2009 to 2015
# using CSV, DataFrames
# using Printf

# # Define the years, months, and the variable names of interest
# years = 2009:2015
# months = ["ene", "feb", "mar", "abr", "may", "jun", "jul", "ago", "sep", "oct", "nov", "dic"]
# vars_of_interest = ["ro", "ho", "re", "he", "c", "nt"]
# months_dict = Dict(lowercase(m) => lpad(i, 2, '0') for (i, m) in enumerate(months))

# # Base path for your data
# base_path = "_data\\_IRCMO\\"

# # Function to rename columns
# function rename_columns!(df, months_dict)
#     for col in names(df)
#         # Attempt to match the month name and replace it with its numeric representation
#         for (month_name, month_num) in months_dict
#             if occursin("($month_name)", col)
#                 new_col_name = replace(col, " ($month_name)" => "_$month_num")
#                 rename!(df, col => Symbol(new_col_name))
#                 break # Exit the loop once a replacement is made
#             end
#         end
#     end
# end

# for yy in years
#     println("Processing year: ", yy)

#     # Assuming there's only one CSV file per folder, dynamically get the file name
#     dir_path = joinpath(base_path, "$(yy)")
#     files = readdir(dir_path)
#     csv_file = filter(f -> occursin("$(yy).csv", f), files)[1]
#     full_file_path = joinpath(dir_path, csv_file)

#     if isfile(full_file_path)
#         df = CSV.read(full_file_path, DataFrame, delim = ';')

#         #convert all column names to lowercase for consistency
#         rename!(df, lowercase.(names(df)))
    
#         #renaming columns to var_monthnum
#         rename_columns!(df, months_dict)

#         # Initialize an empty DataFrame for the stacked data
#         stacked_df = DataFrame()

#         for month in months
#             # Extract month number from the dictionary
#             month_num = months_dict[lowercase(month)]
#             println("Processing month: ", month_num)
#             # println(typeof(month_num))

#             # Filter the columns for the current month
#             month_vars = [var * "_" * lpad(month_num, 2, '0') for var in vars_of_interest if var * "_" * lpad(month_num, 2, '0') in names(df)]
            
#             if !isempty(month_vars)
                
#                 # Select the first 8 columns, month-specific columns, and create a monthnum column
#                 temp_df = select(df, 1:8, month_vars)
#                 temp_df[:, :mes] .= parse(Int64,month_num)
#                 temp_df[:, :ano] .= yy
#                 temp_df.tt = map(x-> parse(Int64,string(x)[1]),temp_df.tt)

#                 # Rename the month-specific columns to generic names without the month number
#                 rename!(temp_df, Dict(zip(month_vars, vars_of_interest)))

#                 # println(names(temp_df))

#                 # Generate the expected column names for this month
#                 expected_cols = [var * "_" * month_num for var in vars_of_interest]
                
#                 if  isequal(month_num,"01")

#                     stacked_df = vcat(stacked_df, temp_df)
#                     # println(names(stacked_df))
#                 else
#                     # println(names(temp_df))
#                     if yy != 2015
#                         select!(temp_df,Not([:ro_01]))
#                     end
#                     # println(names(temp_df))
#                     stacked_df = vcat(stacked_df, temp_df)
#                 end
#             end
#         end
#         if yy <=2013
#             old_names = ["empresa_generica" "tt" "id_division"]
#         else
#             old_names = ["empresa_generica" "tt" "division"]
#         end
#         new_names = ["id" "tamano" "div"]
#         rename!(stacked_df,Dict(zip(old_names,new_names)))
#         select!(stacked_df,Not([:tamano_empresa, :re,:he]))
#         stacked_df = stacked_df[:,[:ano,:mes ,:id ,:tamano, :categoria, :sexo, :grupo ,:div, :ro, :ho, :c, :nt]]

#         # Stack or concatenate this month's DataFrame with the accumulated DataFrame
#         CSV.write(joinpath(dir_path, "$(yy)_combined.csv"), stacked_df)
                
#     else
#         println("File not found for year ", yy, ": ", full_file_path)
#     end

# end


