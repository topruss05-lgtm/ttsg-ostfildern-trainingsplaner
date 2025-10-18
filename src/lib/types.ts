export type UserRole = 'trainer' | 'player';

export interface User {
	id: string;
	email: string;
	name: string;
	role: UserRole;
	passwordHash: string;
}

export interface Training {
	id: string;
	date: string;
	time: string;
	maxParticipants: number;
	trainerId: string;
	trainerName: string;
}

export interface Attendance {
	id: string;
	trainingId: string;
	userId: string;
	userName: string;
	status: 'attending' | 'cancelled';
	timestamp: string;
}
