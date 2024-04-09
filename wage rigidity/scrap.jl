using DataFrames, CSV, Statistics

base_path = "_data\\_IRCMO\\"

dir_path = joinpath(base_path, "2009")
files = readdir(dir_path)
csv_file = filter(f -> occursin(".csv", f), files)[1]
full_file_path = joinpath(dir_path,csv_file)

df = CSV.read(full_file_path,DataFrame)

sort!(df, [:id, :tamano, :categoria, :sexo, :grupo, :div, :mes])

gdf = groupby(df, [:id, :tamano, :categoria, :sexo, :grupo, :div])

df.roh = combine(gdf, :ro => (x-> 100 .* x ./ first(skipmissing(x))) => :roh)[:, :roh]

# Regroup by 'mes' if necessary
monthly_gdf = groupby(df, :mes)

# Calculate the adjusted average of 'ro_normalized', handling missing and NaN
monthly_average = combine(monthly_gdf, :roh => mean => :ir_monthly)

# Display the result
display(monthly_average)
