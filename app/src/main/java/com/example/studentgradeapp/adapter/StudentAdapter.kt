package com.example.studentgradeapp.adapter

import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.TextView
import androidx.core.content.ContextCompat
import androidx.recyclerview.widget.DiffUtil
import androidx.recyclerview.widget.ListAdapter
import androidx.recyclerview.widget.RecyclerView
import com.example.studentgradeapp.R
import com.example.studentgradeapp.data.Student

/**
 * RecyclerView adapter that displays a list of [Student] objects.
 * Uses [ListAdapter] + [DiffUtil] for efficient updates.
 */
class StudentAdapter : ListAdapter<Student, StudentAdapter.StudentViewHolder>(DiffCallback()) {

    // ── ViewHolder ────────────────────────────────────────────────────────

    inner class StudentViewHolder(itemView: View) : RecyclerView.ViewHolder(itemView) {
        private val tvName:    TextView = itemView.findViewById(R.id.tvStudentName)
        private val tvId:      TextView = itemView.findViewById(R.id.tvStudentId)
        private val tvAverage: TextView = itemView.findViewById(R.id.tvAverage)
        private val tvGrade:   TextView = itemView.findViewById(R.id.tvFinalGrade)

        fun bind(student: Student) {
            tvName.text    = student.studentName
            tvId.text      = "ID: ${student.studentId}"
            tvAverage.text = "Avg: ${"%.1f".format(student.average ?: 0.0)}"
            tvGrade.text   = student.finalGrade ?: "–"

            // Colour-code the grade badge
            val badgeColor = when (student.finalGrade) {
                "A"  -> R.color.grade_a
                "B"  -> R.color.grade_b
                "C"  -> R.color.grade_c
                "D"  -> R.color.grade_d
                else -> R.color.grade_f        // "F" or null
            }
            tvGrade.backgroundTintList =
                ContextCompat.getColorStateList(itemView.context, badgeColor)
        }
    }

    // ── Adapter overrides ─────────────────────────────────────────────────

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): StudentViewHolder {
        val view = LayoutInflater.from(parent.context)
            .inflate(R.layout.item_student, parent, false)
        return StudentViewHolder(view)
    }

    override fun onBindViewHolder(holder: StudentViewHolder, position: Int) {
        holder.bind(getItem(position))
    }

    // ── DiffCallback ──────────────────────────────────────────────────────

    private class DiffCallback : DiffUtil.ItemCallback<Student>() {
        override fun areItemsTheSame(old: Student, new: Student) =
            old.studentId == new.studentId

        override fun areContentsTheSame(old: Student, new: Student) =
            old == new
    }
}
