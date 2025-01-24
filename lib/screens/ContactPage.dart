import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:contacts_service/contacts_service.dart';


class ContactsPage extends StatefulWidget {
  @override
  _ContactsPageState createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  TextEditingController searchController = TextEditingController();
  List<Contact>? allContacts;
  List<Contact>? displayedContacts;

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    final permissionStatus = await Permission.contacts.request();
    if (permissionStatus.isGranted) {
      try {
        final contacts = await ContactsService.getContacts();
        setState(() {
          allContacts = contacts.toList();
          displayedContacts = allContacts!.take(100).toList();
        });
      } catch (e) {
        print('Error loading contacts: $e');
      }
    } else {
      print('Contacts permission denied');
    }
  }




  void _filterContacts(String query) {
    if (allContacts != null) {
      final filteredContacts = allContacts!
          .where((contact) =>
      contact.displayName?.toLowerCase().contains(query.toLowerCase()) ??
          false)
          .toList();
      setState(() {
        displayedContacts = filteredContacts;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select a contact'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              onChanged: _filterContacts,
              decoration: InputDecoration(
                hintText: 'Search contact',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          Expanded(
            child: displayedContacts == null
                ? Center(
              child: CircularProgressIndicator(),
            )
                : ListView.builder(
              itemCount: displayedContacts!.length,
              itemBuilder: (context, index) {
                final contact = displayedContacts![index];
                return ListTile(
                  title: Text(contact.displayName ?? ''),
                  onTap: () {
                    Navigator.pop(context, contact);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}


class ContactList extends StatefulWidget {
  const ContactList({Key? key}) : super(key: key);

  @override
  State<ContactList> createState() => _ContactListState();
}

class _ContactListState extends State<ContactList> {
  TextEditingController nameController = TextEditingController();
  TextEditingController contactController = TextEditingController();
  List<Contacts> contacts = [];

  int selectedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Contacts List'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            const SizedBox(height: 10),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                hintText: 'Contact Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(10),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: contactController,
              keyboardType: TextInputType.number,
              maxLength: 10,
              decoration: const InputDecoration(
                hintText: 'Contact Number',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(10),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _saveContact,
                  child: const Text('Save'),
                ),
                ElevatedButton(
                  onPressed: selectedIndex != -1 ? _updateContact : null,
                  child: const Text('Update'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            contacts.isEmpty
                ? const Text(
              'No Contact yet..',
              style: TextStyle(fontSize: 22),
            )
                : Expanded(
              child: ListView.builder(
                itemCount: contacts.length,
                itemBuilder: (context, index) => getRow(index),
              ),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addContactFromDevice,
        child: Icon(Icons.add),
      ),
    );
  }

  Future<void> _addContactFromDevice() async {
    // Check if contacts permission is granted
    if (await Permission.contacts.request().isGranted) {
      // Open device contact list
      final Contact? selectedContact = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ContactsPage(),
        ),
      );

      // If a contact is selected, add it to the list
      if (selectedContact != null) {
        setState(() {
          String name = selectedContact.displayName ?? '';
          String contact = selectedContact.phones?.isNotEmpty ?? false
              ? selectedContact.phones!.first.value ?? ''
              : '';
          contacts.add(Contacts(name: name, contact: contact));
        });
      }
    } else {
      // Handle case when permission is denied
      print('Contacts permission denied');
    }
  }








  void _saveContact() {
    String name = nameController.text.trim();
    String contact = contactController.text.trim();
    if (name.isNotEmpty && contact.isNotEmpty) {
      setState(() {
        nameController.text = '';
        contactController.text = '';
        contacts.add(Contacts(name: name, contact: contact));
      });
    }
  }

  void _updateContact() {
    String name = nameController.text.trim();
    String contact = contactController.text.trim();
    if (name.isNotEmpty && contact.isNotEmpty) {
      setState(() {
        nameController.text = '';
        contactController.text = '';
        contacts[selectedIndex].name = name;
        contacts[selectedIndex].contact = contact;
        selectedIndex = -1;
      });
    }
  }

  Widget getRow(int index) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: index % 2 == 0 ? Colors.deepPurpleAccent : Colors.purple,
          foregroundColor: Colors.white,
          child: Text(
            contacts[index].name[0],
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              contacts[index].name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(contacts[index].contact),
          ],
        ),
        trailing: SizedBox(
          width: 70,
          child: Row(
            children: [
              InkWell(
                onTap: () {
                  nameController.text = contacts[index].name;
                  contactController.text = contacts[index].contact;
                  setState(() {
                    selectedIndex = index;
                  });
                },
                child: const Icon(Icons.edit),
              ),
              InkWell(
                onTap: () {
                  setState(() {
                    contacts.removeAt(index);
                  });
                },
                child: const Icon(Icons.delete),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Contacts {
  String name;
  String contact;
  Contacts({required this.name, required this.contact});
}
