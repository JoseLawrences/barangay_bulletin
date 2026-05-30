# barangay_bulletin

A offline community reporting and announcements app, Perfect for digital community integration.

## Features
- Local Persistence Later: Program runs on Hive and Hive Flutter, which allows offline-first data storage
- State Management Architecture: Implemented using built-in 'setState' mechanics. and native state lifecycles to enforce strict state control boundaries.
- Dynamic Local Queuries: Incorporates reactive 'ValueListenableBuilder' listeners for automated UI paint updates when underlying database objects change.
- Soft-Delete Integrity Framework: Includes a way to delete entries but still have the option to restore upfront (ArchiveScreen).

### Setting up

- Step 1 - > Clone/Reolocate Project
    Make sure project directory is loaded onto a file system
- Step 2 -> Download Dependencies and Packages
    Open VSCode's terminal and input the following:
    ```bash
    flutter clean
    flutter pub get

