using CSV, DataFrames
using FilePathsBase

function safe_lowercase(s)
    try
        return lowercase(s)
    catch e
        if isa(e, Base.InvalidCharError)
            println("Warning: Invalid character found in string: ", s)
            return s  # Devuelve la cadena original si hay un error
        else
            rethrow(e)
        end
    end
end

#region: Monthly data from mar 2019 to dec 2019
# Define the months array

yy = 2019
println("Year: ", yy)

# Initialize an empty DataFrame for the year
year_data = DataFrame()
months = ["mar", "abr", "may", "jun", "jul", "ago", "sep", "oct", "nov", "dic"]

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
        monthly_data = CSV.read(monthly_data_path, DataFrame, delim=';',  encoding="UTF-8")
        ponderadores_data = CSV.read(ponderadores_path, DataFrame, delim=';', encoding="UTF-8")
        
        # Trim spaces from column names for both DataFrames
        rename!(monthly_data, strip.(String.(names(monthly_data))))
        rename!(ponderadores_data, strip.(String.(names(ponderadores_data))))
        
        # Convert all column names to lowercase for consistency using safe_lowercase
        rename!(monthly_data, safe_lowercase.(names(monthly_data)))
        rename!(ponderadores_data, safe_lowercase.(names(ponderadores_data)))

        # Drop unwanted columns
        cols_to_drop = [:ro_t_1, :ho_t_1, :c_t_1, :ht_t_1]
        select!(monthly_data, Not(cols_to_drop))

        # Merge the monthly data with the Ponderadores data
        merged_data = innerjoin(monthly_data, ponderadores_data, on = [:tamano, :categoria, :sexo, :grupo])

        # If it's the first month ('mar' for 2019), initialize `year_data` with this merged DataFrame
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
# Ensure the directory exists before saving the combined data for the year
combined_path = "_data\\_IRCMO\\$(yy)\\$(yy)_combined.csv"  # Update the path as needed
mkpath(dirname(combined_path))  # Ensure the directory exists
CSV.write(combined_path, year_data)
