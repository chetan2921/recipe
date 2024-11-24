import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_html/flutter_html.dart'; // Add this import

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark().copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 147, 229, 250),
          brightness: Brightness.dark,
          surface: const Color.fromARGB(255, 42, 51, 59),
        ),
        scaffoldBackgroundColor: const Color.fromARGB(255, 50, 58, 60),
      ),
      home: RecipeHomePage(),
    );
  }
}

class RecipeHomePage extends StatefulWidget {
  @override
  _RecipeHomePageState createState() => _RecipeHomePageState();
}

class _RecipeHomePageState extends State<RecipeHomePage> {
  final TextEditingController ingredientController = TextEditingController();
  final String apiKey = '775414b1959946d0a8a9b42485047cc3'; // Replace with your Spoonacular API key
  List<dynamic> _recipes = [];
  String _errorMessage = '';

  Future<void> fetchRecipes(List<String> ingredients) async {
    final query = ingredients.join(',');
    final url = Uri.parse(
        'https://api.spoonacular.com/recipes/complexSearch?apiKey=$apiKey&query=$query');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _recipes = data['results'] ?? [];
          _errorMessage = _recipes.isEmpty ? 'No recipes found' : '';
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load recipes: ${response.reasonPhrase}';
        });
      }
    } catch (error) {
      setState(() {
        _errorMessage = 'Error fetching recipes: $error';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Recipe Recommendation"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: ingredientController,
              decoration: InputDecoration(
                labelText: 'Enter ingredients (comma-separated)',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                List<String> ingredients = ingredientController.text
                    .split(',')
                    .map((e) => e.trim())
                    .toList();
                fetchRecipes(ingredients);
              },
              child: Text('Get Recipes'),
            ),
            SizedBox(height: 16),
            _errorMessage.isNotEmpty
                ? Text(_errorMessage, style: TextStyle(color: Colors.red))
                : _recipes.isEmpty
                    ? Center(child: Text('No recipes found'))
                    : Expanded(
                        child: ListView.builder(
                          itemCount: _recipes.length,
                          itemBuilder: (context, index) {
                            return Card(
                              child: ListTile(
                                leading: Image.network(_recipes[index]['image']),
                                title: Text(_recipes[index]['title']),
                                onTap: () async {
                                  final recipeId = _recipes[index]['id'];
                                  final detailUrl = Uri.parse(
                                      'https://api.spoonacular.com/recipes/$recipeId/information?apiKey=$apiKey');
                                  try {
                                    final response = await http.get(detailUrl);
                                    if (response.statusCode == 200) {
                                      final recipeDetail =
                                          json.decode(response.body);
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => RecipeDetailPage(
                                            recipe: recipeDetail,
                                          ),
                                        ),
                                      );
                                    }
                                  } catch (error) {
                                    print(
                                        'Error fetching recipe details: $error');
                                  }
                                },
                              ),
                            );
                          },
                        ),
                      ),
          ],
        ),
      ),
    );
  }
}

class RecipeDetailPage extends StatelessWidget {
  final dynamic recipe;

  RecipeDetailPage({required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(recipe['title'] ?? 'Recipe Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (recipe['image'] != null)
                Image.network(recipe['image'])
              else
                Center(child: Text('Image not available')),
              SizedBox(height: 16),
              Text(
                'Ingredients:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              recipe['extendedIngredients'] != null
                  ? Text(
                      recipe['extendedIngredients']
                          .map((ingredient) => ingredient['original'])
                          .join(', '),
                      style: TextStyle(fontSize: 16),
                    )
                  : Text('Ingredients not available'),
              SizedBox(height: 16),
              Text(
                'Instructions:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              recipe['instructions'] != null
                  ? Html(
                      data: recipe['instructions'], // Render HTML content
                    )
                  : Text('Instructions not available'),
            ],
          ),
        ),
      ),
    );
  }
}