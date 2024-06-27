import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TodoMachine extends StateNotifier<List<Map<String, dynamic>>> {
  TodoMachine() : super([]) {
    loadTodos();
  }

  void loadTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final todos = prefs.getStringList('todos') ?? [];
    state = todos.map((todo) => {'title': todo, 'completed': false}).toList();
  }

  void addTodo(String title) async {
    final prefs = await SharedPreferences.getInstance();
    state = [
      ...state,
      {'title': title, 'completed': false}
    ];
    prefs.setStringList(
        'todos', state.map((todo) => todo['title'] as String).toList());
  }

  void checkTodo(int index) async {
    final prefs = await SharedPreferences.getInstance();
    state = [
      for (int i = 0; i < state.length; i++)
        if (i == index)
          {...state[i], 'completed': !state[i]['completed']}
        else
          state[i]
    ];
    prefs.setStringList(
        'todos', state.map((todo) => todo['title'] as String).toList());
  }

  void removeTodo(int index) async {
    final prefs = await SharedPreferences.getInstance();
    state = [
      for (int i = 0; i < state.length; i++)
        if (i != index) state[i]
    ];
    prefs.setStringList(
        'todos', state.map((todo) => todo['title'] as String).toList());
  }
}

final todoProvider =
    StateNotifierProvider<TodoMachine, List<Map<String, dynamic>>>((ref) {
  return TodoMachine();
});

void main() {
  runApp(const ProviderScope(
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Riverpod TODO app')),
        body: const Center(
          child: TodoWidget(),
        ),
      ),
    );
  }
}

class TodoWidget extends ConsumerStatefulWidget {
  const TodoWidget({super.key});

  @override
  _TodoWidgetState createState() => _TodoWidgetState();
}

class _TodoWidgetState extends ConsumerState<TodoWidget> {
  late TextEditingController todoController;

  @override
  void initState() {
    super.initState();
    todoController = TextEditingController();
  }

  @override
  void dispose() {
    todoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    final todos = ref.watch(todoProvider);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: screenWidth * 0.65,
              child: TextFormField(
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                controller: todoController,
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.add),
                  border: UnderlineInputBorder(),
                  hintText: 'Add your TODO',
                ),
              ),
            ),
            const SizedBox(width: 20),
            ElevatedButton(
              onPressed: () {
                final title = todoController.text;
                if (title.isNotEmpty) {
                  ref.read(todoProvider.notifier).addTodo(title);
                  todoController.clear();
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
        const SizedBox(height: 50),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: ListView.builder(
              itemCount: todos.length,
              itemBuilder: (context, index) {
                final todo = todos[index];

                return Row(
                  children: [
                    SizedBox(
                      width: screenWidth * 0.8,
                      child: Row(
                        children: [
                          Checkbox(
                            value: todo['completed'] as bool,
                            onChanged: (value) {
                              ref.read(todoProvider.notifier).checkTodo(index);
                            },
                          ),
                          SizedBox(
                            width: screenWidth * 0.55,
                            child: Text(
                              todo['title'] as String,
                              style: TextStyle(
                                fontSize: 20,
                                color: todo['completed'] as bool
                                    ? Colors.grey
                                    : Colors.black,
                                fontWeight: FontWeight.bold,
                                decoration: todo['completed'] as bool
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                              ),
                            ),
                          ),
                          Spacer(),
                          IconButton(
                            icon: Icon(Icons.close),
                            onPressed: () {
                              ref.read(todoProvider.notifier).removeTodo(index);
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
