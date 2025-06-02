defmodule TspSolver.TestRunner do
  @moduledoc """
  Modul untuk menjalankan dan menganalisis test cases TSP.

  Menyediakan berbagai fungsi untuk menjalankan test cases,
  menganalisis performa, dan memvalidasi hasil.
  """

  @doc """
  Menjalankan semua test cases.
  """
  def run_all do
    IO.puts("Menjalankan semua test cases TSP...")
    IO.puts("=" |> String.duplicate(60))

    TspSolver.TestCases.get_all_cases()
    |> Enum.with_index(1)
    |> Enum.each(fn {{name, matrix, expected}, index} ->
      IO.puts("\n#{index}. #{name}")
      run_single_test(matrix, expected)
    end)

    IO.puts("Semua test cases selesai dijalankan!")
  end

  @doc """
  Menjalankan test cases berdasarkan ukuran.

  ## Parameters
  - `size`: Jumlah kota
  """
  def run_by_size(size) do
    IO.puts("Menjalankan test cases dengan #{size} kota...")
    IO.puts("=" |> String.duplicate(50))

    cases = TspSolver.TestCases.get_cases_by_size(size)

    if Enum.empty?(cases) do
      IO.puts("Tidak ada test case dengan #{size} kota.")
    else
      cases
      |> Enum.with_index(1)
      |> Enum.each(fn {{name, matrix, expected}, index} ->
        IO.puts("\n#{index}. #{name}")
        run_single_test(matrix, expected)
      end)
    end
  end

  @doc """
  Menjalankan test cases berdasarkan kategori.

  ## Parameters
  - `category`: :small, :medium, atau :large
  """
  def run_by_category(category) do
    category_name = case category do
      :small -> "Kecil (3-4 kota)"
      :medium -> "Sedang (5-6 kota)"
      :large -> "Besar (7+ kota)"
      _ -> "Semua"
    end

    IO.puts("Menjalankan test cases kategori #{category_name}...")
    IO.puts("=" |> String.duplicate(50))

    TspSolver.TestCases.get_cases_by_category(category)
    |> Enum.with_index(1)
    |> Enum.each(fn {{name, matrix, expected}, index} ->
      IO.puts("\n#{index}. #{name}")
      run_single_test(matrix, expected)
    end)
  end

  @doc """
  Menjalankan benchmark untuk menganalisis performa.
  """
  def run_benchmark do
    IO.puts("Benchmark Performa TSP Algorithm")
    IO.puts("=" |> String.duplicate(50))

    results = TspSolver.TestCases.get_all_cases()    |> Enum.map(fn {name, matrix, expected} ->
      IO.write("Testing #{name}... ")

      # Run multiple times untuk mendapat rata-rata yang akurat
      times = Enum.map(1..5, fn _ ->
        {_cost, _path, time} = TspSolver.TSP.solve(matrix)
        time
      end)

      avg_time = Enum.sum(times) / length(times)
      {cost, path, _} = TspSolver.TSP.solve(matrix)

      IO.puts("[OK] #{Float.round(avg_time, 2)}ms")

      %{
        name: name,
        cities: length(matrix),
        cost: cost,
        path: path,
        avg_time: avg_time,
        expected: expected
      }
    end)

    print_benchmark_summary(results)
  end

  @doc """
  Memvalidasi semua test cases.
  """
  def validate_all do
    IO.puts("Validasi semua matriks test cases...")
    IO.puts("=" |> String.duplicate(50))

    TspSolver.TestCases.get_all_cases()
    |> Enum.with_index(1)
    |> Enum.each(fn {{name, matrix, _expected}, index} ->
      IO.write("#{index}. #{name}: ")

      case TspSolver.TSP.validate_matrix(matrix) do
        :ok ->
          IO.puts("[OK] Valid")
        {:error, reason} ->
          IO.puts("[ERROR] Error: #{reason}")
      end
    end)
  end

  @doc """
  Menjalankan test case tunggal dengan output detail.

  ## Parameters
  - `matrix`: Matriks jarak antar kota
  - `expected`: Biaya optimal yang diharapkan (optional)
  """
  def run_single_test(matrix, expected \\ nil) do
    # Validasi matrix terlebih dahulu
    case TspSolver.TSP.validate_matrix(matrix) do
      :ok ->
        print_matrix(matrix)
        {cost, path, time} = TspSolver.TSP.solve(matrix)
        IO.puts("Minimum Cost: #{cost}")
        IO.puts("Optimal Path: #{Enum.join(path, " → ")}")
        IO.puts("Execution Time: #{time} ms")

        # Bandingkan dengan expected jika ada
        if expected do
          status = if cost == expected, do: "[OK]", else: "[WARNING]"
          IO.puts("Expected Cost: #{expected} #{status}")
        end

      {:error, reason} ->
        IO.puts("Matrix tidak valid: #{reason}")
    end

    IO.puts("-" |> String.duplicate(40))
  end

  # Private functions
  defp print_matrix(matrix) do
    IO.puts("Distance Matrix:")
    Enum.each(matrix, fn row ->
      formatted_row = row
      |> Enum.map(fn x -> String.pad_leading("#{x}", 3) end)
      |> Enum.join(" ")
      IO.puts("   #{formatted_row}")
    end)
  end
  defp print_benchmark_summary(results) do
    IO.puts("\nBenchmark Summary:")
    IO.puts("=" |> String.duplicate(60))

    # Group by city count
    grouped = Enum.group_by(results, & &1.cities)
    Enum.each(grouped, fn {city_count, group_results} ->
      IO.puts("\n#{city_count} Cities:")

      avg_time = group_results
      |> Enum.map(& &1.avg_time)
      |> Enum.sum()
      |> Kernel./(length(group_results))

      min_time = group_results |> Enum.map(& &1.avg_time) |> Enum.min()
      max_time = group_results |> Enum.map(& &1.avg_time) |> Enum.max()
      IO.puts("   Cases: #{length(group_results)}")
      IO.puts("   Avg Time: #{Float.round(avg_time, 2)}ms")
      IO.puts("   Min Time: #{Float.round(min_time, 2)}ms")
      IO.puts("   Max Time: #{Float.round(max_time, 2)}ms")
    end)

    # Overall stats
    all_times = Enum.map(results, & &1.avg_time)
    overall_avg = Enum.sum(all_times) / length(all_times)
    IO.puts("\nOverall Performance:")
    IO.puts("   Total Cases: #{length(results)}")
    IO.puts("   Overall Avg: #{Float.round(overall_avg, 2)}ms")
    IO.puts("   Best Time: #{Float.round(Enum.min(all_times), 2)}ms")
    IO.puts("   Worst Time: #{Float.round(Enum.max(all_times), 2)}ms")
  end
end
