public class DailyScheduleJob implements Schedulable{
    public void execute(System.SchedulableContext sc) {
        DailyBatchJob job = new DailyBatchJob();
        Database.executeBatch(job);
    }
}