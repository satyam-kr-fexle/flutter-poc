import 'package:flutter/material.dart';
import 'add_user_dialog.dart';

List<Map<String, String>> userList = [
  {
    'name': 'John Doe',
    'class': '10th',
    'email': 'john.doe@example.com',
    'phone': '9876543210',
    'address': '123 Main Street, City',
    'joining_date': '01/01/2024',
  },
  {
    'name': 'Jane Smith',
    'class': '8th',
    'email': 'jane.smith@example.com',
    'phone': '8765432109',
    'address': '456 Oak Avenue, Town',
    'joining_date': '15/02/2024',
  },
  {
    'name': 'Jane Don',
    'class': '9th',
    'email': 'jane.don@example.com',
    'phone': '8765430109',
    'address': '456 Oak Avenue, Town',
    'joining_date': '15/02/2023',
  },
];

class HomeBody extends StatefulWidget {
  final Function(void Function(BuildContext)) onDialogCallback;

  const HomeBody({super.key, required this.onDialogCallback});

  @override
  State<HomeBody> createState() => _HomeBodyState();
}

class _HomeBodyState extends State<HomeBody> {
  int _currentPage = 0;
  final int _itemsPerPage = 2;

  @override
  void initState() {
    super.initState();
    widget.onDialogCallback(showAddUserDialog);
  }

  @override
  Widget build(BuildContext context) {
    // Calculate total pages
    final totalPages = (userList.length / _itemsPerPage).ceil();

    // Ensure current page is valid
    if (_currentPage >= totalPages && totalPages > 0) {
      _currentPage = totalPages - 1;
    }

    // Slice the list for current page
    final startIndex = _currentPage * _itemsPerPage;
    final endIndex = (startIndex + _itemsPerPage < userList.length)
        ? startIndex + _itemsPerPage
        : userList.length;

    final currentUsers = userList.isEmpty
        ? <Map<String, String>>[]
        : userList.sublist(startIndex, endIndex);

    return Scaffold(
      backgroundColor: Colors.grey[100], // 🎨 Light grey background
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: Colors.deepPurple, // 🎨 Premium color
        title: Text(
          "Student Directory",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: userList.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No users found',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    'Tap the + button to add a new user',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: EdgeInsets.all(16),
                    itemCount: currentUsers.length,
                    itemBuilder: (context, index) {
                      final user = currentUsers[index];
                      // Calculate actual index for delete/edit operations
                      final actualIndex = startIndex + index;

                      final String name = user['name'] ?? 'Unknown';
                      final String initials = name.isNotEmpty
                          ? name.substring(0, 1).toUpperCase()
                          : '?';

                      return Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: LinearGradient(
                              colors: [Colors.white, Colors.blue.shade50],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 28,
                                      backgroundColor: Colors.deepPurpleAccent,
                                      child: Text(
                                        initials,
                                        style: TextStyle(
                                          fontSize: 24,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            name,
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.deepPurple.shade50,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              border: Border.all(
                                                color:
                                                    Colors.deepPurple.shade100,
                                              ),
                                            ),
                                            child: Text(
                                              'Class: ${user['class']}',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.deepPurple,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // 📝 Action Buttons (Edit/Delete)
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: Icon(
                                            Icons.edit_outlined,
                                            color: Colors.blue,
                                          ),
                                          onPressed: () => showEditUserDialog(
                                            context,
                                            actualIndex,
                                          ),
                                        ),
                                        IconButton(
                                          icon: Icon(
                                            Icons.delete_outline,
                                            color: Colors.red,
                                          ),
                                          onPressed: () =>
                                              deleteUser(actualIndex),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Divider(
                                  height: 24,
                                  thickness: 1,
                                  color: Colors.grey[200],
                                ),
                                // 📋 Details Section
                                _buildInfoRow(
                                  Icons.email_outlined,
                                  user['email'] ?? 'N/A',
                                ),
                                SizedBox(height: 8),
                                _buildInfoRow(
                                  Icons.phone_outlined,
                                  user['phone'] ?? 'N/A',
                                ),
                                SizedBox(height: 8),
                                _buildInfoRow(
                                  Icons.location_on_outlined,
                                  user['address'] ?? 'N/A',
                                ),
                                SizedBox(height: 8),
                                _buildInfoRow(
                                  Icons.calendar_today_outlined,
                                  'Joined: ${user['joining_date'] ?? 'N/A'}',
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                    separatorBuilder: (context, index) => SizedBox(height: 12),
                  ),
                ),
                // Pagination Controls
                if (totalPages > 1)
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        top: BorderSide(color: Colors.grey.shade200),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: Offset(0, -5),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _currentPage > 0
                              ? () {
                                  setState(() {
                                    _currentPage--;
                                  });
                                }
                              : null,
                          icon: Icon(Icons.arrow_back),
                          label: Text("Previous"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: Colors.grey.shade300,
                          ),
                        ),
                        Text(
                          "Page ${_currentPage + 1} of $totalPages",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[700],
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: _currentPage < totalPages - 1
                              ? () {
                                  setState(() {
                                    _currentPage++;
                                  });
                                }
                              : null,
                          icon: Icon(Icons.arrow_forward),
                          label: Text(
                            "Next",
                          ), // Replaced child with label for standard button style
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: Colors.grey.shade300,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 14, color: Colors.grey[800]),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  void showAddUserDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AddUserDialog(
        onUserAdded: (userData) {
          setState(() {
            userList.add(userData);
          });
        },
      ),
    );
  }

  void showEditUserDialog(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (context) => AddUserDialog(
        userData: userList[index],
        isEdit: true,
        onUserAdded: (userData) {
          setState(() {
            userList[index] = userData;
          });
        },
      ),
    );
  }

  void deleteUser(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete User'),
        content: Text('Are you sure you want to delete this user?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              setState(() {
                userList.removeAt(index);
                // Adjust page if empty
                final totalPages = (userList.length / _itemsPerPage).ceil();
                if (_currentPage >= totalPages && _currentPage > 0) {
                  _currentPage--;
                }
              });
              Navigator.pop(context);
            },
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }
}
