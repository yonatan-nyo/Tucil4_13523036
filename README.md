# TSP Solver with Dynamic Programming Algorithm Implementation

![Demo](demo.png)

Implementasi algoritma Dynamic Programming (DP) untuk menyelesaikan masalah TSP.

## Struktur Proyek

```
Tucil4_13523036/
├── mix.exs              # Konfigurasi proyek Elixir Mix
├── README.md            # Dokumentasi proyek
├── lib/                 # Modul utama
│   └── tsp_solver/      # Folder untuk modul TSP Solver
│       ├── application.ex  # Modul aplikasi utama
│       ├── cli.ex          # Modul CLI untuk interaksi pengguna
│       ├── test_cases.ex   # Koleksi test cases
│       ├── test_runner.ex  # Engine untuk menjalankan test cases
│       └── tsp.ex          # Implementasi algoritma TSP
└── test/                # Unit test
    ├── test_helper.exs
    └── tsp_solver_test.exs
```

## Cara Menjalankan

### **Method 1: Build dan Run dengan Escript (Recommended)**

```bash
# Build the escript executable once
mix escript.build

# Then run it in interactive mode
./tsp_solver

# Or with specific commands
./tsp_solver all
./tsp_solver benchmark
./tsp_solver validate
./tsp_solver small
```

### **Method 2: Run dengan Mix**

```bash
# Interactive mode
mix run -e "TspSolver.CLI.main()"

# Run with specific commands
mix run -e "TspSolver.CLI.main(['all'])"
mix run -e "TspSolver.CLI.main(['benchmark'])"
mix run -e "TspSolver.CLI.main(['validate'])"
mix run -e "TspSolver.CLI.main(['small'])"
```

### **Menu Interaktif**

Interactive mode menampilkan menu dengan opsi:

1. Run all test cases
2. Run by category (small/medium/large)
3. Run by city count (3-7)
4. Benchmark analysis
5. Validate matrices
6. Custom matrix input
7. Show help
8. Exit

### **Command Line Options**

```bash
# Menjalankan semua test cases
./tsp_solver all

# Benchmark performa dengan analisis statistik
./tsp_solver benchmark

# Validasi semua matrix test cases
./tsp_solver validate

# Filter berdasarkan kategori
./tsp_solver small      # 3-4 cities
./tsp_solver medium     # 5-6 cities
./tsp_solver large      # 7+ cities

# Filter berdasarkan jumlah kota spesifik
./tsp_solver 4          # Hanya 4-city problems
./tsp_solver 5          # Hanya 5-city problems

# Bantuan
./tsp_solver help
```

## Sample Output

### **Test Case Example:**

```
Distance Matrix:
     0  12  18  24
    12   0  42  30
    18  42   0  36
    24  30  36   0
Minimum Cost: 96
Optimal Path: 0 → 1 → 3 → 2 → 0
Execution Time: 2 ms
```

## Author

13523036 - Yonatan Edward Njoto
