# Stark Group VMS

Vehicle management system: Flutter Web frontend, Spring Boot REST API, SQL database.

## Features
- Login screen (default account: **admin** / **admin123**, password stored as a BCrypt hash)
- Vehicle list with search
- Register, edit and delete vehicles
- Duplicate vehicle number validation (case-insensitive, enforced by the service and a unique database constraint)
- Data stored in a real SQL database (H2 file database by default, MySQL optional)

## REST API (http://localhost:8080/api/vehicles)
| Method | Path | Purpose |
|--------|------|---------|
| POST | /api/auth/login | Sign in (401 if the username or password is wrong) |
| GET | /api/vehicles | List vehicles |
| GET | /api/vehicles/{id} | Get one vehicle |
| POST | /api/vehicles | Register a vehicle (409 if the number exists) |
| PUT | /api/vehicles/{id} | Edit a vehicle (409 if the number belongs to another vehicle) |
| DELETE | /api/vehicles/{id} | Delete a vehicle |

## Run the backend
Requires Java 17 or newer.
1. Open the `backend` folder in IntelliJ IDEA or VS Code (Java extensions) and run `VmsApplication`,
   or from the `backend` folder run: `mvn spring-boot:run`
2. API: http://localhost:8080/api/vehicles
3. Database console (H2): http://localhost:8080/h2-console
   JDBC URL `jdbc:h2:file:./data/vmsdb`, user `sa`, empty password.

To use MySQL instead, edit `backend/src/main/resources/application.properties` (instructions inside).

## Run the frontend
1. `flutter create vms_frontend`
2. `cd vms_frontend`
3. `flutter pub add http`
4. Delete the generated `lib` folder and copy this project's `frontend/lib` folder in its place.
5. `flutter run -d chrome`

The backend must be running first. The API address is set in `lib/services/api_service.dart`.
