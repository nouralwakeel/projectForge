<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('success_estimations', function (Blueprint $table) {
            $table->dropForeign(['user_id']);
            $table->renameColumn('user_id', 'student_id');
            $table->foreign('student_id')->references('id')->on('students')->onDelete('cascade');
        });
    }

    public function down(): void
    {
        Schema::table('success_estimations', function (Blueprint $table) {
            $table->dropForeign(['student_id']);
            $table->renameColumn('student_id', 'user_id');
            $table->foreign('user_id')->references('id')->on('users')->onDelete('cascade');
        });
    }
};
