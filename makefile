all:
	antlr4 Cactus.g4   
	javac Cactus*.java 
	grun Cactus program < input_file.txt > output_file.txt 

clean:
	del *.class *.tokens *.java *.interp