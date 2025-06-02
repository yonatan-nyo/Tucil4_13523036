defmodule TspSolver.CLI do
  @moduledoc """
  CLI module untuk menjalankan TSP solver dengan berbagai opsi.

  Dapat dijalankan dalam mode interaktif atau dengan command line arguments.
  """

  alias TspSolver.TestRunner

  def main(args \\ []) do
    case args do
      [] ->
        interactive_mode()

      ["all"] ->
        TestRunner.run_all()

      ["benchmark"] ->
        TestRunner.run_benchmark()

      ["validate"] ->
        TestRunner.validate_all()

      ["small"] ->
        TestRunner.run_by_category(:small)

      ["medium"] ->
        TestRunner.run_by_category(:medium)

      ["large"] ->
        TestRunner.run_by_category(:large)

      [size_str] when size_str in ["3", "4", "5", "6", "7"] ->
        size = String.to_integer(size_str)
        TestRunner.run_by_size(size)

      ["help"] ->
        show_help()

      _ ->
        IO.puts("Invalid arguments. Use 'help' to see available options.")
        show_help()
    end
  end

  defp interactive_mode do
    IO.puts("""
    TSP Solver with Dynamic Programming Algorithm Implementation
    ============================================================

    Pilih opsi yang tersedia:

    1.  Run all test cases
    2.  Run by category (small/medium/large)
    3.  Run by city count
    4.  Run benchmark analysis
    5.  Validate all matrices
    6.  Custom matrix input
    7.  Show help
    0.  Exit

    """)

    choice = IO.gets("Pilih opsi (0-7): ") |> String.trim()

    case choice do
      "1" ->
        TestRunner.run_all()
        continue_prompt()

      "2" ->
        IO.puts("\nPilih kategori:")
        IO.puts("1. Small (3-4 cities)")
        IO.puts("2. Medium (5-6 cities)")
        IO.puts("3. Large (7+ cities)")

        cat_choice = IO.gets("Pilih kategori (1-3): ") |> String.trim()

        category =
          case cat_choice do
            "1" -> :small
            "2" -> :medium
            "3" -> :large
            _ -> :small
          end

        TestRunner.run_by_category(category)
        continue_prompt()

      "3" ->
        size_input = IO.gets("Masukkan jumlah kota (3-7): ") |> String.trim()

        case Integer.parse(size_input) do
          {size, ""} when size in 3..7 ->
            TestRunner.run_by_size(size)

          _ ->
            IO.puts("Jumlah kota harus antara 3-7")
        end

        continue_prompt()

      "4" ->
        TestRunner.run_benchmark()
        continue_prompt()

      "5" ->
        TestRunner.validate_all()
        continue_prompt()

      "6" ->
        custom_input_mode()
        continue_prompt()

      "7" ->
        show_help()
        continue_prompt()

      "0" ->
        IO.puts("Terima kasih telah menggunakan TSP Solver!")

      _ ->
        IO.puts("Pilihan tidak valid. Silakan coba lagi.")
        interactive_mode()
    end
  end

  defp custom_input_mode do
    IO.puts("\nCustom Matrix Input Mode")
    IO.puts("=" |> String.duplicate(30))

    size_input = IO.gets("Masukkan jumlah kota: ") |> String.trim()

    case Integer.parse(size_input) do
      {size, ""} when size > 0 and size <= 10 ->
        IO.puts("Masukkan matriks jarak #{size}x#{size}:")
        IO.puts("Format: masukkan setiap baris dipisah dengan spasi")
        IO.puts("Contoh untuk 3 kota: 0 2 9")

        matrix = collect_matrix_input(size, [])

        case TspSolver.TSP.validate_matrix(matrix) do
          :ok ->
            IO.puts("\nMatrix valid, menjalankan TSP solver...")
            TestRunner.run_single_test(matrix)

          {:error, reason} ->
            IO.puts("Matrix tidak valid: #{reason}")
        end

      _ ->
        IO.puts("Jumlah kota harus berupa angka positif (max 10)")
    end
  end

  defp collect_matrix_input(0, acc), do: Enum.reverse(acc)

  defp collect_matrix_input(remaining, acc) do
    row_input = IO.gets("Baris #{length(acc) + 1}: ") |> String.trim()

    row =
      row_input
      |> String.split()
      |> Enum.map(&String.to_integer/1)

    collect_matrix_input(remaining - 1, [row | acc])
  end

  defp continue_prompt do
    continue = IO.gets("\nLanjutkan? (y/n): ") |> String.trim() |> String.downcase()

    case continue do
      "y" -> interactive_mode()
      "yes" -> interactive_mode()
      _ -> IO.puts("Terima kasih!")
    end
  end

  defp show_help do
    IO.puts("""

    TSP Solver Help
    ==================

    Command Line Usage:
    -------------------
    elixir cli.ex                 # Interactive mode
    elixir cli.ex all             # Run all test cases
    elixir cli.ex benchmark       # Performance analysis
    elixir cli.ex validate        # Validate all matrices
    elixir cli.ex small           # Run small test cases (3-4 cities)
    elixir cli.ex medium          # Run medium test cases (5-6 cities)
    elixir cli.ex large           # Run large test cases (7+ cities)
    elixir cli.ex 4               # Run test cases with specific city count
    """)
  end
end
