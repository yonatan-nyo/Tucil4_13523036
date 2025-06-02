defmodule TspSolver.TSP do
  @moduledoc """
  Implementasi algoritma untuk Travelling Salesman Problem (TSP).

  Modul ini menyediakan implementasi algoritma dynamic programming
  untuk menyelesaikan TSP secara optimal.
  """

  import Bitwise

  @inf 999_999_999

  @doc """
  Menyelesaikan TSP untuk matriks jarak `matrix`.

  ## Parameters
  - `matrix`: Matriks jarak antar kota (list of lists)

  ## Returns
  Tuple `{biaya_minimum, jalur, waktu_eksekusi_ms}` dimana:
  - `biaya_minimum`: Total biaya perjalanan minimum
  - `jalur`: List berisi urutan kota yang dikunjungi
  - `waktu_eksekusi_ms`: Waktu eksekusi dalam milidetik

  ## Examples
      iex> matrix = [[0, 10, 15, 20], [10, 0, 35, 25], [15, 35, 0, 30], [20, 25, 30, 0]]
      iex> {cost, path, _time} = TSP.solve(matrix)
      iex> cost
      80
      iex> path
      [0, 1, 3, 2, 0]
  """
  def solve(matrix) do
    start_time = System.monotonic_time(:millisecond)

    n = length(matrix)
    size = 1 <<< n

    # Inisialisasi tabel DP dan predecessor
    dp = :array.new(size, default: :array.new(n, default: @inf))
    pre = :array.new(size, default: :array.new(n, default: -1))

    # Base case: mulai dari kota 0
    dp = update_dp(dp, 1, 0, 0)

    # Dynamic programming dengan bitmask
    {dp, pre} =
      Enum.reduce(0..(size - 1), {dp, pre}, fn mask, {dp_acc, pre_acc} ->
        Enum.reduce(0..(n - 1), {dp_acc, pre_acc}, fn i, {dp_acc2, pre_acc2} ->
          if (mask &&& (1 <<< i)) != 0 do
            old_mask = mask &&& bnot(1 <<< i)

            Enum.reduce(0..(n - 1), {dp_acc2, pre_acc2}, fn j, {dp_acc3, pre_acc3} ->
              if (mask &&& (1 <<< j)) != 0 and j != i do
                prev_cost = get_dp(dp_acc3, old_mask, j)
                cost = prev_cost + get_matrix(matrix, j, i)

                if cost < get_dp(dp_acc3, mask, i) do
                  new_dp = update_dp(dp_acc3, mask, i, cost)
                  new_pre = update_pre(pre_acc3, mask, i, j)
                  {new_dp, new_pre}
                else
                  {dp_acc3, pre_acc3}
                end
              else
                {dp_acc3, pre_acc3}
              end
            end)
          else
            {dp_acc2, pre_acc2}
          end
        end)
      end)

    # Mencari biaya minimum untuk kembali ke kota asal
    {min_cost, last} =
      Enum.reduce(1..(n - 1), {@inf, -1}, fn i, {min_cost, last} ->
        cost = get_dp(dp, size - 1, i) + get_matrix(matrix, i, 0)

        if cost < min_cost do
          {cost, i}
        else
          {min_cost, last}
        end
      end)

    # Rekonstruksi jalur optimal
    path = reconstruct_path(pre, last, size - 1, [0])

    end_time = System.monotonic_time(:millisecond)
    elapsed_time = end_time - start_time

    {min_cost, path, elapsed_time}
  end

  @doc """
  Memvalidasi matriks jarak TSP.

  ## Parameters
  - `matrix`: Matriks jarak yang akan divalidasi

  ## Returns
  - `:ok` jika matriks valid
  - `{:error, reason}` jika matriks tidak valid
  """
  def validate_matrix(matrix) do
    cond do
      not is_list(matrix) or length(matrix) == 0 ->
        {:error, "Matrix harus berupa list non-empty"}

      not Enum.all?(matrix, &is_list/1) ->
        {:error, "Setiap row harus berupa list"}

      not square_matrix?(matrix) ->
        {:error, "Matrix harus berbentuk persegi (n x n)"}

      not symmetric_matrix?(matrix) ->
        {:error, "Matrix harus simetris"}

      not zero_diagonal?(matrix) ->
        {:error, "Diagonal utama harus bernilai 0"}

      not non_negative_matrix?(matrix) ->
        {:error, "Semua elemen harus non-negatif"}

      true ->
        :ok
    end
  end

  # Private functions untuk operasi DP

  defp get_dp(dp, mask, i) do
    dp_row = :array.get(mask, dp)
    :array.get(i, dp_row)
  end

  defp update_dp(dp, mask, i, value) do
    dp_row = :array.get(mask, dp)
    dp_row = :array.set(i, value, dp_row)
    :array.set(mask, dp_row, dp)
  end

  defp update_pre(pre, mask, i, value) do
    pre_row = :array.get(mask, pre)
    pre_row = :array.set(i, value, pre_row)
    :array.set(mask, pre_row, pre)
  end

  defp get_matrix(matrix, i, j) do
    matrix
    |> Enum.at(i)
    |> Enum.at(j)
  end

  defp reconstruct_path(pre, current, mask, acc) do
    if mask == 1 do
      Enum.reverse([current | acc])
    else
      pre_row = :array.get(mask, pre)
      prev = :array.get(current, pre_row)
      reconstruct_path(pre, prev, mask &&& bnot(1 <<< current), [current | acc])
    end
  end

  # Private functions untuk validasi matrix

  defp square_matrix?(matrix) do
    n = length(matrix)
    Enum.all?(matrix, fn row -> length(row) == n end)
  end

  defp symmetric_matrix?(matrix) do
    n = length(matrix)

    Enum.all?(0..(n-1), fn i ->
      Enum.all?(0..(n-1), fn j ->
        get_matrix(matrix, i, j) == get_matrix(matrix, j, i)
      end)
    end)
  end

  defp zero_diagonal?(matrix) do
    n = length(matrix)

    Enum.all?(0..(n-1), fn i ->
      get_matrix(matrix, i, i) == 0
    end)
  end

  defp non_negative_matrix?(matrix) do
    Enum.all?(matrix, fn row ->
      Enum.all?(row, fn elem -> elem >= 0 end)
    end)
  end
end
