using CSV, DataFrames

# Function to preprocess and clean numeric fields
function clean_numeric_fields(file_path)
    clean_lines = []
    open(file_path, "r") do file
        for line in eachline(file)
            # Replace periods used as thousands separators with nothing
            # This step needs to be adjusted based on your specific data format and requirements
            clean_line = replace(line, "." => "")
            push!(clean_lines, clean_line)
        end
    end
    return clean_lines
end


# Base path for your data
base_path = "_data\\_IRCMO\\2007"
files = readdir(base_path)
print(files)
csv_file = filter(f->occursin("2007.csv",f),files)[1]
full_file_path = joinpath(base_path,csv_file)

cleaned_data = clean_numeric_fields(full_file_path)

# Convert the cleaned data into a DataFrame
df = CSV.File(IOBuffer(join(cleaned_data, "\n")), delim=';', decimal=',') |> DataFrame

old_names = ["ID_generico" "Seccion" "Div_generica" "Tamano" "Factor_Expansion_Tamano" "GO" "Sexo"]
new_names = ["id" "seccion" "div" "tamano" "factor_expansion" "grupo" "sexo"]

rename!(df, Dict(zip(old_names,new_names)))
rename!(df, lowercase.(names(df)))
rename!(df, strip.(String.(names(df))))

println(typeof(df.ro))

df.ro = coalesce.(df.ro,0)

numerator = df.ro .* df.factor_expansion
denominator = sum(numerator)
df[:, :pondw] .= numerator ./ denominator
select!(df,Not([:ro,:re,:c,:ho,:he,:ht,:nt ]))
CSV.write(joinpath(base_path, "2007_ponderadores_nuevo.csv"), df)