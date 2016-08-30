require 'csv'
require 'json'

def mesh_init 

  mesh = []
  for i in (0..$mesh_size)
    mesh[i] = []
    for  j in (0..$mesh_size)
      if (i==0 || j==0 || j==$mesh_size)
        mesh[i][j] = $To  
      elsif i==$mesh_size
        mesh[i][j] = $Ta
      else
        mesh[i][j] = 0.0
      end 
    end
  end    

  return mesh

end

def solve_mesh mesh

    for i in (1..$mesh_size-1)
      for j in (1..$mesh_size-1)
        mesh[i][j] = 0.25 * (mesh[i][j-1] + mesh[i][j+1] + mesh[i-1][j] + mesh[i+1][j])
      end
    end

  return mesh

end

def yet_to_converge mesh , mesh_copy

  for i in  (1..$mesh_size-1)
    for j in (1..$mesh_size-1)
      if (((mesh[i][j] - mesh_copy[i][j]) / mesh[i][j]).abs > $tolerance_value)
        return true
      end
    end
  end

  return false

end

def write_into_csv mesh , filename

  File.delete(filename) if File.exists? filename
  width_list = []
  for i in (0..$mesh_size+1)
    if i==0 
      width_list.push(" ")
    else
      width_list.push("L = " + ((i-1)*$length/$mesh_size).to_s)
    end
  end
  puts "Started storing mesh values into excel file - #{filename}."
  CSV.open(filename, "a") do |csv|
    csv << width_list
  end
  for i in (0..mesh.length-1)
    CSV.open(filename, "a") do |csv|
      mesh[i].insert(0,"H = " + (i*$height/$mesh_size).to_s)
      csv << mesh[i]
    end
  end

  puts "Successfully stored mesh values into excel file - #{filename}."
    
end

def get_mesh mesh

  m = []
  for i in (0..$mesh_size)
    m[i] = []
    for  j in (0..$mesh_size)      
        m[i][j] = mesh[i][j]  
    end
  end    

  return m

end

def get_temp

  mesh = []
  for i in (0..$mesh_size)
    mesh[i] = []
    for j in (0..$mesh_size)
      x = j*$length/$mesh_size
      y = i*$height/$mesh_size
      pre = 4.0 * ($Ta - $To)
      sum = 0.0
      for k in (1..100)
        n = 2*k - 1
        val1 = Math.sin(n*3.14*($length-x)/$length)
        val2 = Math.sinh(n*3.14*y/$length)
        val3 = 3.14*n*Math.sinh(n*3.14*$height/$length)
        sum = sum + ((val1 * val2) / val3)
      end
      temp =  $To + pre*sum
      mesh[i][j] = temp 
    end
  end    

  return mesh

end

def get_difference mesh1 , mesh2

  diff = 0
  for i in (0..$mesh_size)
    for j in (0..$mesh_size)
      diff = diff + ((mesh1[i][j]) - (mesh2[i][j])).abs
    end
  end

  return diff

end

def write_into_json csv_file

  json_file = csv_file.gsub(".csv","")
  data = CSV.read(csv_file)
  data2 , data3 = [] , []
  for i in (0..$mesh_size)
    x , y = data[0][i] , data[i][0]  
    x , y = x.gsub("L = ","") , y.gsub("H = ","")
    data2.push(x.to_f)
    data3.push(y.to_f)
  end
  data2.push($length)
  data3.push($height)
  data.delete_at(0)
  for i in (0..$mesh_size)
    data[i].delete_at(0)
  end
  for i in (0..data.length-1)
    for j in (0..data.length-1)
      data[i][j] = data[i][j].to_f
    end
  end
  data2.delete_at(0)
  data3.delete_at(0)
  File.delete(json_file+".json") if File.exists? json_file+".json"
  File.delete(json_file+"_x.json") if File.exists? json_file+"_x.json"
  File.delete(json_file+"_y.json") if File.exists? json_file+"_y.json"
  File.open(json_file+".json", "a") { |file| file.write(JSON.generate(data)) }
  File.open(json_file+"_x.json", "a") { |file| file.write(JSON.generate(data2)) }
  File.open(json_file+"_y.json", "a") { |file| file.write(JSON.generate(data3)) }


end

$height = 1.0
$length = 1.5
$mesh_size = 200.0
$To = 100.0
$Ta = 120.0
$tolerance_value = 0.001
k = 1
mesh = mesh_init()
mesh_copy = get_mesh(mesh)
puts "Successfully created a mesh of size #{$mesh_size} x #{$mesh_size}."

mesh = solve_mesh(mesh)

while yet_to_converge(mesh,mesh_copy)
  mesh_copy = get_mesh(mesh)
  mesh = solve_mesh(mesh)
  puts "[Iteration] #{k} successfully completed."
  k = k+1
end  
puts "\nTook #{k-1} iterations to solve the mesh of size #{$mesh_size} x #{$mesh_size}, with tolerance level of #{$tolerance_value*100}%. "

theory_mesh = get_temp()
# value = get_difference(mesh,theory_mesh)

write_into_csv(mesh,"numerical_analysis.csv")
write_into_csv(theory_mesh,"theoretical_analysis.csv")
write_into_json("numerical_analysis.csv")
write_into_json("theoretical_analysis.csv")

# puts "\n\n DIFFERENCE : #{value}"