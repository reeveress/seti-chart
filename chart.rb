require 'Sketchup.rb'
require 'csv'

class CSVMeshImporter < Sketchup::Importer

	def description
		return 'CSV to mesh importer (*.csv)'
	end

	def file_extension
		return 'csv'
	end

	def id
		return 'com.sketchup.importers.rpchk.csvmesh'
	end

	def supports_options?
		return false
	end

	def load_file(filepath = "~/Library/'Application Support'/'SketchUp 2015'/SketchUp/Plugins/seti/seti_surveys.csv",status=true)
puts "Loading File #{filepath}"
puts "Loaded File"

		sky_coverage = []
		frequency0 = []
		frequencyend = []
		#sensitivity = []
		
		model = Sketchup.active_model
		entities = model.entities
		material = model.materials
#		#xy-plane
#		pt0 = [0,0]
#		pt1 = [0,50]
#		pt2 = [50, 50]
#		pt3 = [50, 0]
#		entities.add_face pt0, pt1, pt2, pt3
#		#yz-plane
#		pt0 = [0,0,0]
#		pt1 = [0,0,50]
#		pt2 = [0,50,50]
#		pt3 = [0,50,0]
#		
#		
#		entities.add_face pt0, pt1, pt2, pt3
#making the grid 
n = 60
m = 100
s = 1.1
w = 1
(0..n-1).each { |i|
	(0..m-1).each { |j|
		face = entities.add_face [i*s,j*s],[i*s,j*s+w],[i*s+w,j*s+w],[i*s+w,j*s]

         }

  }

n = 60
m=100
s = 1.1
w = 1
(0..m-1).each { |i|
	(0..n-1).each { |j|
		face = entities.add_face [0,i*s,j*s],[0,i*s,j*s+w],[0,i*s+w,j*s+w],[0,i*s+w,j*s]

	}
  }

#labeling axes
(0..n-1).each { |i|

	group = entities.add_group()
	group.entities.add_3d_text(i.to_s(10), TextAlignRight, 'Arial',  false, false, 1.0, 0.0, 0, true)

#	transformation = Geom::Transformation.rotation(ORIGIN, X_AXIS, 90.degrees)
#	if i >  10
#		j = 1.5
#	else
#		j = 0
#	end
	
	transformation = Geom::Transformation.translation([i+1,-1]) 
	transformation *= Geom::Transformation.rotation(ORIGIN, Z_AXIS, 90.degrees)
	group.transform!(transformation)

}


		CSV.foreach(filepath, converters: :all, headers: :true){
			|a|
		
			#model = Sketchup.active_model
			#entities = model.entities
			if a[1] ==  nil 
				break
			end
			
			new_comp_def = Sketchup.active_model.definitions.add('bar')
			

			sky_coverage = a[1]
			frequency0 = a[2]
			frequencyend = a[3]
			#sensitivity = a[3]
			puts a[1]	
			pt0 = [0, frequency0]
			pt1 = [sky_coverage, frequency0]
			pt2 = [sky_coverage, frequencyend]
			pt3 = [0, frequencyend]
			
			newface = new_comp_def.entities.add_face pt0, pt1, pt2,pt3
			newface.reverse! if newface.normal.z <0
			color = "%06x" % (rand * 0xffffff)
			newface.material = color
			newface.material.alpha = 0.5
			newface.pushpull a[4]
			#new_face = entities.add_face pt0, pt1, pt2, pt3
			#new_face.material = 'blue'
			
			#new_face.pushpull -a[4]

			trans = Geom::Transformation.new
			Sketchup.active_model.active_entities.add_instance(new_comp_def,trans)
			group = entities.add_group()
			group.entities.add_3d_text(a[0], TextAlignLeft, 'Arial',  true, false, 1.0, 0.0, 0, true)

			transformation = Geom::Transformation.rotation(ORIGIN, X_AXIS, 90.degrees)
			transformation *= Geom::Transformation.translation([0,a[4]-1,-frequency0]) 
			group.transform!(transformation)
		}

	
	return 0
	

	end
end

Sketchup.register_importer(CSVMeshImporter.new)


